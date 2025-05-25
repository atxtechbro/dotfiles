#!/bin/bash

# =========================================================
# GIT MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Git MCP server
# This script is called by the MCP system during normal operation
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# No fallback - ride or die with the built version
exec node "$SCRIPT_DIR/servers/git-mcp-server/dist/index.js"
