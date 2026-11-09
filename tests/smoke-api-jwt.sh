#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApi --db-name demo_api --db-user teacher --target "$TMP" --no-install
PROJECT="$TMP/DemoApi"

test -f "$PROJECT/public/index.php"
test -s "$PROJECT/docs/guide-utilisation.md"
grep -q "Profil API JWT" "$PROJECT/docs/guide-utilisation.md"
grep -q 'docs/guide-utilisation.md' "$PROJECT/README.md"
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
grep -q '"mithridatem/router": "\^1.7.1"' "$PROJECT/composer.json"
grep -q 'new Application' "$PROJECT/public/index.php"
test -f "$PROJECT/src/Kernel/Application.php"
test -f "$PROJECT/src/Kernel/RouterFactory.php"
test -f "$PROJECT/src/Kernel/ApiBootstrap.php"
test -f "$PROJECT/src/Kernel/ApiErrorHandler.php"
test -f "$PROJECT/tests/api_kernel_test.php"
test -f "$PROJECT/src/Kernel/EnvironmentLoader.php"
test -f "$PROJECT/tests/environment_loader_test.php"
test -f "$PROJECT/docs/environments.md"
grep -q 'RouteGroup' "$PROJECT/src/Controller/Api/AuthController.php"
grep -q 'RouteGroup' "$PROJECT/src/Controller/Api/ProfileController.php"
grep -q 'JWT_TTL_SECONDS=900' "$PROJECT/.env"
grep -q "'ttl'" "$PROJECT/config/service.php"
grep -q 'setMiddlewareResolver' "$PROJECT/src/Kernel/RouterFactory.php"
grep -q 'RequestAuthenticationMiddleware::class' "$PROJECT/src/Kernel/RouterFactory.php"
! grep -q 'new Router' "$PROJECT/public/index.php"
grep -q "JwtMiddleware::class" "$PROJECT/src/Controller/Api/ProfileController.php"
if grep -R -Eq "^[[:space:]]*session_start[[:space:]]*\\(" "$PROJECT/src/Kernel" "$PROJECT/public/index.php"; then
  echo "L'API ne doit pas démarrer de session PHP" >&2
  exit 1
fi
grep -q '^DATABASE_NAME=demo_api$' "$PROJECT/.env"
grep -q 'CREATE DATABASE IF NOT EXISTS `demo_api`' "$PROJECT/db.sql"
grep -q 'CREATE TABLE IF NOT EXISTS `user`' "$PROJECT/db.sql"
if grep -Eiq 'CREATE TABLE.*(book|lending|category)' "$PROJECT/db.sql"; then
  echo 'Le scaffold API JWT ne doit pas contenir de tables métier' >&2
  exit 1
fi
grep -q '^JWT_ISSUER=mvc-starterPERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q '^JWT_AUDIENCE=mvc-starter-api
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q "'issuer' => \$_ENV\['JWT_ISSUER'\] ?? 'mvc-starter'" "$PROJECT/config/service.php"
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q '^JWT_AUDIENCE=mvc-starter-apiPERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q '^JWT_AUDIENCE=mvc-starter-api
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q "'issuer' => \$_ENV\['JWT_ISSUER'\] ?? 'mvc-starter'" "$PROJECT/config/service.php"
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -Fq "'issuer' => \$_ENV['JWT_ISSUER'] ?? 'mvc-starter'" "$PROJECT/config/service.php"
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q '^JWT_AUDIENCE=mvc-starter-api
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
 "$PROJECT/.env"
grep -q "'issuer' => \$_ENV\['JWT_ISSUER'\] ?? 'mvc-starter'" "$PROJECT/config/service.php"
PERMS="$(php -r 'echo decoct(fileperms($argv[1]) & 0777);' "$PROJECT/.env")"
test "$PERMS" = "600" || { echo '.env permissions are not private' >&2; exit 1; }

# The generated secret must be random, valid hex and must differ across projects.
SECRET="$(sed -n 's/^JWT_SECRET=//p' "$PROJECT/.env")"
[[ "$SECRET" =~ ^[0-9a-f]{64}$ ]] || { echo "Invalid JWT secret" >&2; exit 1; }
! grep -q "__JWT_SECRET__" "$PROJECT/.env"
bash "$ROOT/bin/create-project.sh" --profile api-jwt --name DemoApiTwo --target "$TMP" --no-install
SECOND="$(sed -n 's/^JWT_SECRET=//p' "$TMP/DemoApiTwo/.env")"
[[ "$SECRET" != "$SECOND" ]] || { echo "JWT secrets must be unique" >&2; exit 1; }

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
test -f "$PROJECT/tests/jwt_security_edge_test.php"
grep -q 'JWT_TTL_SECONDS must be a positive integer' "$PROJECT/src/Security/Jwt/JwtTokenManager.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$PROJECT/composer.json"
while IFS= read -r -d '' file; do php -l "$file" >/dev/null; done < <(find "$PROJECT" -name '*.php' -print0)
echo "API JWT scaffold : OK"
