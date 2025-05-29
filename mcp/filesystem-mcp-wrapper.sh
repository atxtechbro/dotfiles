#!/bin/bash

# =========================================================
# FILESYSTEM MCP SERVER WRAPPER SCRIPT
# =========================================================
# PURPOSE: Wrapper script for the Filesystem MCP server
# This version uses our custom fork with modified tool descriptions
# that de-emphasize the edit and write functions
# =========================================================

# Get the directory where this wrapper script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the path to the built server
BUILT_SERVER_PATH="$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server/dist/index.js"

# Check if the built server exists
if [ -f "$BUILT_SERVER_PATH" ]; then
    echo "Using locally built custom Filesystem MCP server..."
    # Pass all arguments to the built server
    # The $HOME argument allows access to the home directory
    node "$BUILT_SERVER_PATH" "$HOME" "$@"
else
    echo "Built server not found, falling back to npx..."
    echo "Warning: This will use the standard version without custom tool descriptions"
    # Fall back to npx if the built server doesn't exist
    npx @modelcontextprotocol/filesystem-server "$HOME" "$@"
fi
