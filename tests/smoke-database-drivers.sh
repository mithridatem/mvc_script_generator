#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for profile in basic advanced api-jwt; do
  for driver in mysql pgsql sqlite; do
    name="Test_${profile//-/_}_$driver"
    bash "$ROOT/bin/create-project.sh" --name "$name" --profile "$profile" \
      --db-driver "$driver" --target "$TMP" --no-install
    project="$TMP/$name"
    grep -Fqx "DATABASE_DRIVER=$driver" "$project/.env"
    test -f "$project/src/Database/ConnectionFactory.php"
    test -f "$project/src/Database/ConnectionInterface.php"
    test -d "$project/var"
    test -f "$project/tests/database_connection_test.php"
    if [[ "$driver" == "pgsql" ]]; then
      grep -Fqx 'DATABASE_PORT=5432' "$project/.env"
    fi
    if [[ "$driver" == "sqlite" ]]; then
      grep -Fqx 'DATABASE_PATH=var/database.sqlite' "$project/.env"
    fi
    if [[ "$profile" != "basic" ]]; then
      test -f "$project/database/postgresql.sql"
      test -f "$project/database/sqlite.sql"
    fi
  done
done

if bash "$ROOT/bin/create-project.sh" --name InvalidDriver --profile basic \
   --db-driver oracle --target "$TMP" --no-install >/dev/null 2>&1; then
  echo 'Le script a accepté un driver inconnu.' >&2
  exit 1
fi

if bash "$ROOT/bin/create-project.sh" --name InvalidSqlitePassword --profile advanced \
   --db-driver sqlite --configure-db --target "$TMP" --no-install >/dev/null 2>&1; then
  echo 'Le script a accepté --configure-db avec SQLite.' >&2
  exit 1
fi

echo 'Database driver scaffold options : OK'
