#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"

usage() {
  cat <<'USAGE'
Usage: bash install-local.sh [--bin-dir CHEMIN]

Installe la commande « mvc » pour le compte utilisateur, sans Composer ni Packagist.
Le dépôt source doit rester à son emplacement actuel : la commande pointe vers lui.
Par défaut, le lanceur est créé dans ~/.local/bin.
USAGE
}

while (($#)); do
  case "$1" in
    --bin-dir)
      if (($# < 2)) || [[ -z "$2" ]]; then
        echo "Chemin manquant pour --bin-dir" >&2
        exit 2
      fi
      BIN_DIR="$2"
      shift 2
      ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Option inconnue : $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -f "$ROOT/bin/create-project.sh" ]] || { echo "Moteur du générateur introuvable." >&2; exit 1; }
mkdir -p "$BIN_DIR"
BIN_DIR="$(cd "$BIN_DIR" && pwd)"
DEST="$BIN_DIR/mvc"

if [[ -e "$DEST" ]] && ! grep -Fq '# mvc_script_generator local launcher' "$DEST" 2>/dev/null; then
  echo "Un fichier non géré existe déjà : $DEST" >&2
  echo "Installation annulée pour éviter de l'écraser." >&2
  exit 1
fi

# Quotes the repository path safely (including spaces) for a Bash launcher.
printf -v SCRIPT_PATH '%q' "$ROOT/bin/create-project.sh"
{
  printf '%s\n' '#!/usr/bin/env bash'
  printf '%s\n' '# mvc_script_generator local launcher'
  printf 'exec bash %s "$@"\n' "$SCRIPT_PATH"
} > "$DEST"
chmod 755 "$DEST"

echo "Commande installée : $DEST"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  printf '%s\n' "Ajoute $BIN_DIR à ton PATH si nécessaire :"
  printf '  export PATH="%s:$PATH"\n' "$BIN_DIR"
  echo 'Place cette ligne dans ~/.bashrc ou ~/.zshrc pour la rendre permanente.'
fi
echo 'Exemple : mvc --profile advanced --name demo_web --target ~/projets'
