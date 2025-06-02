#!/bin/bash

# =========================================================
# GIT MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Git MCP server
# This script is called by the MCP system during normal operation
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the Git MCP server directory
SERVER_DIR="$SCRIPT_DIR/servers/git-mcp-server"

# Activate the virtual environment and run the Python module
source "$SERVER_DIR/.venv/bin/activate"
exec python -m mcp_server_git "$@"
