#!/usr/bin/env bash
set -euo pipefail

# Wrapper to launch Playwright MCP through Patchright by default.
#
# Behavior:
# - Default enables Patchright shim by setting NODE_PATH to the shim dir
# - Opt-out by setting USE_PATCHRIGHT=0 or USE_PATCHRIGHT=false
# - Optional debug: USE_PATCHRIGHT_DEBUG=1 prints shim activation to stderr
# - Override underlying command with PLAYWRIGHT_MCP_CMD if needed

USE_PATCHRIGHT="${USE_PATCHRIGHT:-1}"
if [[ "${USE_PATCHRIGHT}" != "0" && "${USE_PATCHRIGHT,,}" != "false" ]]; then
  export NODE_PATH="/home/linuxmint-lp/ppv/pillars/dotfiles/mcp/patchright-shim/node_modules${NODE_PATH+:$NODE_PATH}"
  export USE_PATCHRIGHT_DEBUG="${USE_PATCHRIGHT_DEBUG:-0}"
fi

CMD="${PLAYWRIGHT_MCP_CMD:-npx}"

if [[ "$CMD" == "npx" ]]; then
  exec npx "@playwright/mcp@latest" "$@"
else
  exec "$CMD" "$@"
fi

