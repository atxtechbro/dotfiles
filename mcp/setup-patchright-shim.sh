#!/usr/bin/env bash
set -euo pipefail

# Install Patchright into the local shim so Playwright resolves to Patchright

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHIM_DIR="$SCRIPT_DIR/patchright-shim"

mkdir -p "$SHIM_DIR"

if [[ ! -f "$SHIM_DIR/package.json" ]]; then
  (cd "$SHIM_DIR" && npm init -y >/dev/null 2>&1)
fi

echo "Installing patchright into $SHIM_DIR ..."
(cd "$SHIM_DIR" && npm install patchright --silent)

echo "Patchright shim ready. Optional: download Chromium once with:\n  npx patchright install chromium"

