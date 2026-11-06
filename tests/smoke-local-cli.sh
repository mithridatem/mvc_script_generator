#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

BIN_DIR="$TMP/bin with spaces"
bash "$ROOT/install-local.sh" --bin-dir "$BIN_DIR"
test -x "$BIN_DIR/mvc"
"$BIN_DIR/mvc" --help | grep -q 'Usage:'
# Installing again should be safe and keep the same managed launcher.
bash "$ROOT/install-local.sh" --bin-dir "$BIN_DIR"
# Working directory is the default destination.
mkdir -p "$TMP/work dir"
(cd "$TMP/work dir" && "$BIN_DIR/mvc" --profile basic --name local_project --no-install)
test -f "$TMP/work dir/local_project/public/index.php"
# Explicit --target keeps working across directories with spaces.
mkdir -p "$TMP/output dir"
"$BIN_DIR/mvc" --profile api-jwt --name local_api --target "$TMP/output dir" --no-install
test -f "$TMP/output dir/local_api/public/index.php"
test -f "$TMP/output dir/local_api/.env"
# Never overwrite a pre-existing unmanaged command.
mkdir -p "$TMP/existing"
printf '#!/bin/sh\nexit 0\n' > "$TMP/existing/mvc"
if bash "$ROOT/install-local.sh" --bin-dir "$TMP/existing" >/dev/null 2>&1; then
  echo 'Installer overwrote an existing unmanaged command' >&2
  exit 1
fi
echo 'Local MVC CLI : OK'
