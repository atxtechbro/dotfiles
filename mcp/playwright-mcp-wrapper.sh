#!/bin/bash

# =========================================================
# PLAYWRIGHT MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Playwright MCP server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Path to the Playwright MCP server directory
SERVER_DIR="$SCRIPT_DIR/servers/playwright-mcp"

# Check if server directory exists
if [[ ! -d "$SERVER_DIR" ]]; then
  mcp_log_error "PLAYWRIGHT" "Server directory not found: $SERVER_DIR" "Run setup-playwright-mcp.sh to install the Playwright MCP server"
  exit 1
fi

# Check if node command is available
mcp_check_command "PLAYWRIGHT" "node" "Install Node.js: brew install node"

# Run the server using Node.js
mcp_exec_with_logging "PLAYWRIGHT" "node" "$SERVER_DIR/index.js" "$@"