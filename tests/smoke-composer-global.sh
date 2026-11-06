#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v php >/dev/null || { echo 'PHP is required' >&2; exit 1; }
command -v composer >/dev/null || { echo 'Composer is required' >&2; exit 1; }

# Isolated Composer home: never modify the developer's global packages.
export COMPOSER_HOME="$TMP/composer home"
mkdir -p "$COMPOSER_HOME"
composer global config repositories.mvc path "$ROOT" --no-interaction
composer global require 'mithridatem/mvc-script-generator:@dev' --no-interaction --no-progress --prefer-dist

BIN_DIR="$(composer global config bin-dir --absolute)"
test -f "$BIN_DIR/mvc" || { echo 'Composer did not install mvc binary' >&2; exit 1; }
"$BIN_DIR/mvc" --help | grep -q 'Usage:'

mkdir -p "$TMP/projects with spaces"
for profile in basic advanced api-jwt; do
  name="composer_${profile//-/_}"
  "$BIN_DIR/mvc" --profile "$profile" --name "$name" --target "$TMP/projects with spaces" --no-install
  test -f "$TMP/projects with spaces/$name/public/index.php"
  test -f "$TMP/projects with spaces/$name/composer.json"
  test -f "$TMP/projects with spaces/$name/docs/guide-utilisation.md"
done
test -f "$TMP/projects with spaces/composer_api_jwt/.env"
# Regression: macOS Bash 3.2 does not support lowercase parameter expansion.
"$BIN_DIR/mvc" --profile basic --name DemoUpperCase --target "$TMP/projects with spaces" --no-install
test -d "$TMP/projects with spaces/DemoUpperCase"
grep -q demouppercase "$TMP/projects with spaces/DemoUpperCase/composer.json"
# Backwards compatibility with the historical entry point.
bash "$ROOT/script.sh" --help | grep -q 'Usage:'
composer global remove mithridatem/mvc-script-generator --no-interaction --no-progress
echo 'Composer global MVC CLI : OK'
