#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
bash "$ROOT/bin/create-project.sh" --name DemoAdvanced --profile advanced --db-name demo_school --db-user teacher --target "$TMP" --no-install

PROJECT="$TMP/DemoAdvanced"
test -f "$PROJECT/.env"
test -f "$PROJECT/src/Controller/LoginController.php"
test -f "$PROJECT/src/DTO/RegisterUserInput.php"
test -f "$PROJECT/src/Security/PasswordHasher.php"
test -f "$PROJECT/src/Security/CsrfTokenManager.php"
test -f "$PROJECT/src/Service/UploadFileService.php"
test -f "$PROJECT/public/asset/style/main.css"
test -f "$PROJECT/tests/csrf_token_manager_test.php"
grep -q "getMethod()" "$PROJECT/src/Controller/AbstractController.php"
grep -q "CsrfTokenManager" "$PROJECT/src/Controller/LoginController.php"
grep -q "CsrfTokenManager" "$PROJECT/src/Controller/RegisterController.php"
grep -q 'UPLOAD_DIRECTORY=' "$PROJECT/.env"
grep -q '^DATABASE_NAME=demo_school$' "$PROJECT/.env"
grep -q 'CREATE DATABASE IF NOT EXISTS `demo_school`' "$PROJECT/db.sql"

php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do
  php -l "$file" >/dev/null
done < <(find "$PROJECT" -name '*.php' -print0)
# Le rendu HTML n'appelle plus les anciens helpers CSRF de AbstractController.
if grep -R -E 'getCsrfToken|isCsrfTokenValid' "$PROJECT/src/Controller" "$PROJECT/template"; then
  echo 'Ancien helper CSRF détecté dans le profil advanced' >&2
  exit 1
fi
echo 'Advanced scaffold : OK'
