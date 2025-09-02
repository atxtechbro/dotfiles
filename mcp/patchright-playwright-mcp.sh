#!/usr/bin/env bash
set -euo pipefail

# Wrapper to launch Playwright MCP through Patchright by default.
#
# Behavior:
# - Default enables Patchright shim by setting NODE_PATH to the shim dir
# - Opt-out by setting USE_PATCHRIGHT=0 or USE_PATCHRIGHT=false
# - Optional debug: USE_PATCHRIGHT_DEBUG=1 prints shim activation to stderr
# - Override underlying command with PLAYWRIGHT_MCP_CMD if needed

# Resolve repository-local paths dynamically (no hardcoded absolute paths)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
SHIM_NODE_MODULES="$SCRIPT_DIR/patchright-shim/node_modules"

USE_PATCHRIGHT="${USE_PATCHRIGHT:-1}"
if [[ "${USE_PATCHRIGHT}" != "0" && "${USE_PATCHRIGHT,,}" != "false" ]]; then
  export NODE_PATH="${SHIM_NODE_MODULES}${NODE_PATH+:$NODE_PATH}"
  export USE_PATCHRIGHT_DEBUG="${USE_PATCHRIGHT_DEBUG:-0}"
fi

CMD="${PLAYWRIGHT_MCP_CMD:-npx}"

if [[ "$CMD" == "npx" ]]; then
  exec npx "@playwright/mcp@latest" "$@"
else
  exec "$CMD" "$@"
fi
