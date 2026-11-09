#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
bash "$ROOT/bin/create-project.sh" --name DemoAdvanced --profile advanced --db-name demo_school --db-user teacher --target "$TMP" --no-install

PROJECT="$TMP/DemoAdvanced"
test -f "$PROJECT/.env"
grep -q '^APP_ENV=dev$' "$PROJECT/.env"
grep -Fqx '/.env.*' "$PROJECT/.gitignore"
test -s "$PROJECT/docs/guide-utilisation.md"
grep -q "Profil Advanced Web" "$PROJECT/docs/guide-utilisation.md"
grep -q 'docs/guide-utilisation.md' "$PROJECT/README.md"
test -f "$PROJECT/src/Controller/LoginController.php"
test -f "$PROJECT/src/DTO/RegisterUserInput.php"
test -f "$PROJECT/src/Security/PasswordHasher.php"
test -f "$PROJECT/src/Security/CsrfTokenManager.php"
test -f "$PROJECT/src/Service/UploadFileService.php"
test -f "$PROJECT/public/asset/style/main.css"
test -f "$PROJECT/src/Middleware/CsrfMiddleware.php"
test -f "$PROJECT/src/Middleware/ContainerMiddlewareResolver.php"
test -f "$PROJECT/tests/csrf_middleware_test.php"
test -f "$PROJECT/tests/csrf_route_configuration_test.php"
test -f "$PROJECT/tests/csrf_token_manager_test.php"
test -f "$PROJECT/tests/auth_form_render_test.php"
test -f "$PROJECT/tests/request_dto_mapping_test.php"
grep -q "getMethod()" "$PROJECT/src/Controller/AbstractController.php"
grep -q "CsrfTokenManager" "$PROJECT/src/Controller/LoginController.php"
grep -q "CsrfTokenManager" "$PROJECT/src/Controller/RegisterController.php"
grep -q "allPost()" "$PROJECT/src/Controller/RegisterController.php"
grep -q "allPost()" "$PROJECT/src/Controller/LoginController.php"
grep -q '"mithridatem/router": "\^1.7.1"' "$PROJECT/composer.json"
grep -q '"mithridatem/validation": "\^1.2.1"' "$PROJECT/composer.json"
grep -q '"mithridatem/autowiring": "\^1.4.2"' "$PROJECT/composer.json"
grep -q "middleware: \[CsrfMiddleware::class\]" "$PROJECT/src/Controller/LoginController.php"
grep -q "middleware: \[CsrfMiddleware::class\]" "$PROJECT/src/Controller/RegisterController.php"
grep -q "new Application" "$PROJECT/public/index.php"
test -f "$PROJECT/src/Kernel/Application.php"
test -f "$PROJECT/src/Kernel/RouterFactory.php"
test -f "$PROJECT/src/Kernel/WebBootstrap.php"
test -f "$PROJECT/src/Kernel/WebErrorHandler.php"
test -f "$PROJECT/tests/web_kernel_test.php"
test -f "$PROJECT/tests/guest_navigation_test.php"
test -f "$PROJECT/src/Security/GuestNavigation.php"
test -f "$PROJECT/docs/guest-navigation.md"
grep -q 'AuthenticationAwareGrantChecker' "$PROJECT/src/Kernel/RouterFactory.php"
grep -q "grants: \['IS_GUEST'\]" "$PROJECT/src/Controller/LoginController.php"
grep -q "grants: \['IS_GUEST'\]" "$PROJECT/src/Controller/RegisterController.php"
test -f "$PROJECT/src/Kernel/EnvironmentLoader.php"
test -f "$PROJECT/tests/environment_loader_test.php"
test -f "$PROJECT/docs/environments.md"
test -f "$PROJECT/docs/route-groups-web.md"
grep -q 'RouteGroup' "$PROJECT/src/Controller/LoginController.php"
grep -q 'RouteGroup' "$PROJECT/src/Controller/RegisterController.php"
! grep -q 'FORMS' "$PROJECT/src/Middleware/CsrfMiddleware.php"
grep -q "setMiddlewareResolver" "$PROJECT/src/Kernel/RouterFactory.php"
grep -q "InvalidCsrfTokenException" "$PROJECT/src/Kernel/WebErrorHandler.php"
! grep -q "new Router" "$PROJECT/public/index.php"
! grep -q "session_start(" "$PROJECT/public/index.php"
test ! -e "$PROJECT/src/Middleware/JwtMiddleware.php"
grep -q "renderLoginForm" "$PROJECT/src/Controller/LoginController.php"
grep -q "renderRegisterForm" "$PROJECT/src/Controller/RegisterController.php"
grep -q 'UPLOAD_DIRECTORY=' "$PROJECT/.env"
grep -q '^DATABASE_NAME=demo_school$' "$PROJECT/.env"
grep -q 'CREATE DATABASE IF NOT EXISTS `demo_school`' "$PROJECT/db.sql"
grep -q 'CREATE TABLE IF NOT EXISTS `user`' "$PROJECT/db.sql"
if grep -Eiq 'CREATE TABLE.*(book|lending|category)' "$PROJECT/db.sql"; then
  echo 'Le scaffold advanced ne doit pas contenir de tables métier' >&2
  exit 1
fi

test -f "$PROJECT/tests/security/reproduce_repository_leak.php"
grep -q 'hydrateDate' "$PROJECT/src/Entity/User.php"
! grep -q 'echo \$e->getMessage()' "$PROJECT/src/Repository/UserRepository.php"
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
