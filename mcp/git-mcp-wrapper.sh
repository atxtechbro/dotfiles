#!/bin/bash

# =========================================================
# GIT MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Git MCP server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Path to the Git MCP server directory
SERVER_DIR="$SCRIPT_DIR/servers/git-mcp-server"

# Check if server directory exists
if [[ ! -d "$SERVER_DIR" ]]; then
  mcp_log_error "GIT" "Server directory not found: $SERVER_DIR" "Run setup-git-mcp.sh to install the Git MCP server"
  exit 1
fi

# Check if git command is available
mcp_check_command "GIT" "git" "Install Git: brew install git"

# Run the Python module directly from the venv
mcp_exec_with_logging "GIT" "$SERVER_DIR/.venv/bin/python" -m mcp_server_git "$@"
