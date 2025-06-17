#!/bin/bash

# =========================================================
# FILESYSTEM MCP SERVER WRAPPER SCRIPT
# =========================================================
# PURPOSE: Wrapper script for the Filesystem MCP server
# This version uses our custom fork with modified tool descriptions
# Enhanced with error logging to address MCP client logging limitations
# =========================================================

# Get the directory where this wrapper script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-logging.sh"

# Check if Node.js is available
mcp_check_command "FILESYSTEM" "node" "Install Node.js: brew install node"

# Define the path to the built server
BUILT_SERVER_PATH="$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server/dist/index.js"

# Check if the built server exists
if [[ -f "$BUILT_SERVER_PATH" ]]; then
    echo "Using locally built custom Filesystem MCP server..."
    # Pass all arguments to the built server
    # The $HOME argument allows access to the home directory
    node "$BUILT_SERVER_PATH" "$HOME" "$@"
else
    echo "Built server not found, falling back to npx..."
    echo "Warning: This will use the standard version without custom tool descriptions"
    
    # Check if npx is available
    if ! command -v npx &>/dev/null; then
        mcp_log_error "FILESYSTEM" "Neither built server nor npx found" "Run setup-filesystem-mcp.sh to build the server, or install Node.js: brew install node"
        exit 1
    fi
    
    # Fall back to npx if the built server doesn't exist
    npx @modelcontextprotocol/filesystem-server "$HOME" "$@"
fi
