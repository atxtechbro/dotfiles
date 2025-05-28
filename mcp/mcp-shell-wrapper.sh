#!/bin/bash
#
# mcp-shell-wrapper.sh - Wrapper script for the sonirico/mcp-shell server
#
# This script starts the mcp-shell server with the appropriate configuration.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/mcp-shell.yaml"
MCP_SHELL_BIN="$SCRIPT_DIR/mcp-shell/mcp-shell"

# Check if the binary exists
if [ ! -f "$MCP_SHELL_BIN" ]; then
    echo "Error: mcp-shell binary not found at $MCP_SHELL_BIN"
    echo "Please run utils/install-mcp-shell.sh first"
    exit 1
fi

# Start the server with the configuration file
exec "$MCP_SHELL_BIN" --config "$CONFIG_FILE" "$@"