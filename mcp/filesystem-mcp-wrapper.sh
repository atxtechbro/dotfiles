#!/bin/bash

# =========================================================
# FILESYSTEM MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Filesystem MCP server
# This script is called by the MCP system during normal operation
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if the built version exists
if [ -f "$SCRIPT_DIR/servers/mcp-servers/src/filesystem/dist/index.js" ]; then
    # Use the built version
    exec node "$SCRIPT_DIR/servers/mcp-servers/src/filesystem/dist/index.js" "$HOME"
else
    # Fallback to npx version if build doesn't exist
    echo "Warning: Built version not found, falling back to npx version" >&2
    exec npx -y @modelcontextprotocol/server-filesystem "$HOME"
fi
