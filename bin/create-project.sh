#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE=""
NAME=""
TARGET_PARENT="."
INSTALL="yes"
DB_DRIVER="mysql"
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_NAME=""
DB_USER="root"
CONFIGURE_DB="no"
DB_PORT_EXPLICIT="no"

usage() {
  cat <<'USAGE'
Usage: bash script.sh [--name NOM] [--profile basic|advanced|api-jwt] [--target DOSSIER]
                      [--no-install] [--db-host HOTE] [--db-port PORT]
                      [--db-name BASE] [--db-user UTILISATEUR] [--db-driver mysql|pgsql|sqlite] [--configure-db]
Trois profils : basic (router seul), advanced (Web session + CSRF) ou api-jwt (API Bearer JWT).
--configure-db demande le mot de passe sans affichage (uniquement en mode interactif).
Sans --configure-db, compléter DATABASE_PASSWORD dans le .env généré.
Pour sqlite, initialiser database/sqlite.sql ; pour PostgreSQL, database/postgresql.sql.
USAGE
}

while (($#)); do
  case "$1" in
    --name) NAME="${2:?Nom manquant}"; shift 2 ;;
    --profile) PROFILE="${2:?Profil manquant}"; shift 2 ;;
    --target) TARGET_PARENT="${2:?Chemin manquant}"; shift 2 ;;
    --no-install) INSTALL="no"; shift ;;
    --db-host) DB_HOST="${2:?Hôte manquant}"; shift 2 ;;
    --db-port) DB_PORT="${2:?Port manquant}"; DB_PORT_EXPLICIT="yes"; shift 2 ;;
    --db-driver) DB_DRIVER="${2:?Driver manquant}"; shift 2 ;;
    --db-name) DB_NAME="${2:?Base manquante}"; shift 2 ;;
    --db-user) DB_USER="${2:?Utilisateur manquant}"; shift 2 ;;
    --configure-db) CONFIGURE_DB="yes"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argument inconnu : $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! command -v php >/dev/null 2>&1; then
  echo "PHP est requis (8.2+)." >&2; exit 1
fi

if [[ -z "$NAME" ]]; then
  read -r -p "Nom du projet (lettres, chiffres, _ ou -) : " NAME
fi
if [[ ! "$NAME" =~ ^[a-zA-Z][a-zA-Z0-9]*([_-][a-zA-Z0-9]+)*$ ]]; then
  echo "Nom de projet invalide : $NAME" >&2; exit 2
fi

if [[ -z "$PROFILE" ]]; then
  if [[ -t 0 ]]; then
    read -r -p "Profil [basic/advanced/api-jwt] (basic) : " PROFILE
    PROFILE="${PROFILE:-basic}"
  else
    PROFILE="basic"
  fi
fi

if [[ "$PROFILE" != "basic" && "$PROFILE" != "advanced" && "$PROFILE" != "api-jwt" ]]; then
  echo "Profil inconnu : $PROFILE" >&2; exit 2
fi

if [[ ! -d "$TARGET_PARENT" ]]; then
  echo "Répertoire parent introuvable : $TARGET_PARENT" >&2; exit 2
fi

TARGET_PARENT="$(cd "$TARGET_PARENT" && pwd)"
DEST="$TARGET_PARENT/$NAME"
if [[ -e "$DEST" ]]; then
  echo "Destination déjà existante : $DEST" >&2; exit 2
fi

if [[ "$PROFILE" == "advanced" || "$PROFILE" == "api-jwt" ]]; then
  DB_NAME="${DB_NAME:-$NAME}"
  if [[ ! "$DB_HOST" =~ ^[a-zA-Z0-9_.:-]+$ ||
        ! "$DB_PORT" =~ ^[0-9]{1,5}$ ||
        ! "$DB_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ||
        ! "$DB_USER" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    echo "Paramètre de base de données invalide." >&2; exit 2
  fi
fi

if [[ "$DB_DRIVER" != "mysql" && "$DB_DRIVER" != "pgsql" && "$DB_DRIVER" != "sqlite" ]]; then
  echo "Driver inconnu : $DB_DRIVER (mysql, pgsql, sqlite)" >&2; exit 2
fi
if [[ "$DB_DRIVER" == "pgsql" && "$DB_PORT_EXPLICIT" == "no" ]]; then
  DB_PORT="5432"
fi
if [[ "$CONFIGURE_DB" == "yes" && "$DB_DRIVER" == "sqlite" ]]; then
  echo "--configure-db ne s'applique pas à SQLite." >&2; exit 2
fi
if [[ "$CONFIGURE_DB" == "yes" && "$PROFILE" == "basic" ]]; then
  echo "--configure-db ne concerne que advanced et api-jwt." >&2; exit 2
fi
if [[ "$CONFIGURE_DB" == "yes" && ! -t 0 ]]; then
  echo "--configure-db nécessite un terminal interactif." >&2; exit 2
fi

cp -R "$ROOT/templates/$PROFILE" "$DEST"
# Compatible Bash 3.2 (macOS) : ${NAME,,} requires Bash 4+.
SLUG="$(printf '%s' "$NAME" | LC_ALL=C tr '[:upper:]' '[:lower:]')"
sed "s/__PROJECT_NAME__/$SLUG/g" "$DEST/composer.json" > "$DEST/composer.tmp"
mv "$DEST/composer.tmp" "$DEST/composer.json"
cp "$DEST/.env.example" "$DEST/.env"
sed -i.bak -e "s|^DATABASE_DRIVER=.*|DATABASE_DRIVER=$DB_DRIVER|" "$DEST/.env"
rm -f "$DEST/.env.bak"
if [[ "$PROFILE" == "basic" && "$DB_DRIVER" == "pgsql" ]]; then
  sed -i.bak -e "s|^DATABASE_PORT=.*|DATABASE_PORT=$DB_PORT|" "$DEST/.env"
  rm -f "$DEST/.env.bak"
fi

if [[ "$PROFILE" == "advanced" || "$PROFILE" == "api-jwt" ]]; then
  # Les valeurs non secrètes sont validées avant substitution.
  sed -i.bak -e "s|^DATABASE_HOST=.*|DATABASE_HOST=$DB_HOST|" \
             -e "s|^DATABASE_PORT=.*|DATABASE_PORT=$DB_PORT|" \
             -e "s|^DATABASE_NAME=.*|DATABASE_NAME=$DB_NAME|" \
             -e "s|^DATABASE_USERNAME=.*|DATABASE_USERNAME=$DB_USER|" "$DEST/.env"
  rm -f "$DEST/.env.bak"
  sed "s/__DATABASE_NAME__/$DB_NAME/g" "$DEST/db.sql" > "$DEST/db.sql.tmp"
  mv "$DEST/db.sql.tmp" "$DEST/db.sql"
  if [[ "$PROFILE" == "api-jwt" ]]; then
    # One secret per generated project, never saved to the template or logs.
    JWT_SECRET="$(php -r 'echo bin2hex(random_bytes(32));')"
    sed -i.bak "s|^JWT_SECRET=__JWT_SECRET__$|JWT_SECRET=$JWT_SECRET|" "$DEST/.env"
    rm -f "$DEST/.env.bak"
    unset JWT_SECRET
  fi
  if [[ "$CONFIGURE_DB" == "yes" ]]; then
    read -rs -p "Mot de passe de la base de données (ne sera pas affiché) : " DB_PASS
    printf '\n'
    # json_encode produit une chaîne entre guillemets et échappe les caractères spéciaux.
    DB_QUOTED="$(printf '%s' "$DB_PASS" | php -r 'echo json_encode(stream_get_contents(STDIN), JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES);')"
    grep -v '^DATABASE_PASSWORD=' "$DEST/.env" > "$DEST/.env.tmp"
    printf 'DATABASE_PASSWORD=%s\n' "$DB_QUOTED" >> "$DEST/.env.tmp"
    mv "$DEST/.env.tmp" "$DEST/.env"
    unset DB_PASS DB_QUOTED
  fi
fi
chmod 600 "$DEST/.env"

echo "Projet $PROFILE créé : $DEST"
if [[ "$INSTALL" == "yes" ]]; then
  if command -v composer >/dev/null 2>&1; then
    (cd "$DEST" && composer install)
  else
    echo "Composer absent : lancer 'composer install' dans $DEST" >&2
  fi
fi
echo "Démarrage : cd '$DEST' && php -S 127.0.0.1:8000 -t public"
