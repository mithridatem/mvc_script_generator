#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
bash "$ROOT/bin/create-project.sh" --name DemoMvc --target "$TMP" --no-install
test -f "$TMP/DemoMvc/public/index.php"
test -f "$TMP/DemoMvc/src/Controller/HomeController.php"
test -f "$TMP/DemoMvc/src/Controller/FormController.php"
test -f "$TMP/DemoMvc/templates/form.php"
test -f "$TMP/DemoMvc/tests/form_request_test.php"
grep -Fq 'RequestInterface $request' "$TMP/DemoMvc/src/Controller/FormController.php"
grep -Fq '$request->post(' "$TMP/DemoMvc/src/Controller/FormController.php"
grep -q '"mithridatem/router": "\^1.7.1"' "$TMP/DemoMvc/composer.json"
test -f "$TMP/DemoMvc/.env"
test ! -e "$TMP/DemoMvc/vendor"
test -s "$TMP/DemoMvc/docs/guide-utilisation.md"
grep -q "Profil Basic" "$TMP/DemoMvc/docs/guide-utilisation.md"
grep -q 'docs/guide-utilisation.md' "$TMP/DemoMvc/README.md"
php -l "$TMP/DemoMvc/public/index.php"
php -l "$TMP/DemoMvc/src/Controller/AbstractController.php"
php -l "$TMP/DemoMvc/src/Controller/HomeController.php"
php -l "$TMP/DemoMvc/src/Controller/FormController.php"
php -l "$TMP/DemoMvc/templates/form.php"
php -l "$TMP/DemoMvc/tests/form_request_test.php"
php -r 'json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);' "$TMP/DemoMvc/composer.json"
echo 'Basic scaffold : OK'
