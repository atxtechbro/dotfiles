#!/bin/bash
# Wrapper script for Microsoft Playwright MCP server
# This script handles execution and error handling for the Playwright MCP server

set -e

# Log file for debugging
LOG_FILE="$HOME/.playwright-mcp.log"

# Check if playwright-mcp is installed
if ! command -v playwright-mcp &> /dev/null; then
    echo "Error: playwright-mcp not found. Please run mcp/setup-playwright-mcp.sh first." | tee -a "$LOG_FILE"
    exit 1
fi

# Set default log level if not provided
export FASTMCP_LOG_LEVEL="${FASTMCP_LOG_LEVEL:-ERROR}"

echo "Starting Microsoft Playwright MCP server..." | tee -a "$LOG_FILE"
echo "$(date): Playwright MCP server started" >> "$LOG_FILE"

# Execute the Playwright MCP server
# The exec replaces this shell process with the MCP server process
exec playwright-mcp "$@"

# This part will only execute if exec fails
echo "$(date): Playwright MCP server exited with code $?" >> "$LOG_FILE"
