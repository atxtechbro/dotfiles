#!/bin/bash

# =========================================================
# GIT MCP WRITE WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Git MCP server with full write access
# This script is called by the MCP system during normal operation
# Runs without --read-only flag to enable all operations
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if git command is available
mcp_check_command "GIT-WRITE" "git" "Install Git: apt-get install git"

# Use virtual environment's Python
PYTHON_CMD="$SCRIPT_DIR/servers/git-mcp-server/.venv/bin/python"

# Check if the virtual environment exists
if [[ ! -f "$PYTHON_CMD" ]]; then
  mcp_log_error "GIT-WRITE" "Virtual environment not found" "Run setup-git-mcp.sh to install the Git MCP server"
  exit 1
fi

# Run the server without read-only flag (full access)
mcp_exec_with_logging "GIT-WRITE" "$PYTHON_CMD" -m mcp_server_git "$@"