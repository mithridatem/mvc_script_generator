#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApi --db-name demo_api --db-user teacher --target "$TMP" --no-install
PROJECT="$TMP/DemoApi"

test -f "$PROJECT/public/index.php"
test -f "$PROJECT/src/Controller/Api/AuthController.php"
test -f "$PROJECT/src/Controller/Api/ProfileController.php"
test -f "$PROJECT/src/Middleware/JwtMiddleware.php"
test -f "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
test -f "$PROJECT/src/Security/Authentication/ContextGrantChecker.php"
test -f "$PROJECT/tests/jwt_api_routes_test.php"
test -f "$PROJECT/tests/jwt_authentication_test.php"
test ! -f "$PROJECT/src/Middleware/CsrfMiddleware.php"
test ! -f "$PROJECT/src/Controller/LoginController.php"
test ! -f "$PROJECT/template/template_login.php"
grep -q 'firebase/php-jwt' "$PROJECT/composer.json"
grep -q 'setMiddlewareResolver' "$PROJECT/public/index.php"
grep -q "JwtMiddleware::class" "$PROJECT/src/Controller/Api/ProfileController.php"
if grep -q "session_start(" "$PROJECT/public/index.php"; then
  echo "L'API ne doit pas démarrer de session PHP" >&2
  exit 1
fi
grep -q '^DATABASE_NAME=demo_api$' "$PROJECT/.env"
grep -q 'CREATE DATABASE IF NOT EXISTS `demo_api`' "$PROJECT/db.sql"
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
