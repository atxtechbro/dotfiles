#!/bin/bash

# =========================================================
# GIT MCP WRITE WRAPPER SCRIPT [DEPRECATED]
# =========================================================
# PURPOSE: This script is deprecated. Use git-mcp-wrapper.sh instead.
# The git-read/git-write split has been consolidated into a single git server
# that relies on Git's built-in authentication for security.
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