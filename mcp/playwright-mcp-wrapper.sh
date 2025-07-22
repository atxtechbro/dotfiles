#!/bin/bash
# Wrapper script for Microsoft Playwright MCP server
# This script handles execution and error handling for the Playwright MCP server

set -e

# Log file for debugging
LOG_FILE="$HOME/.playwright-mcp.log"

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if playwright-mcp is installed
if ! command -v playwright-mcp &> /dev/null; then
    echo "playwright-mcp not found. Attempting to install automatically..." | tee -a "$LOG_FILE"
    
    # Check if setup script exists
    if [[ -f "$SCRIPT_DIR/setup-playwright-mcp.sh" ]]; then
        echo "Running setup script..." | tee -a "$LOG_FILE"
        # Make sure it's executable
        chmod +x "$SCRIPT_DIR/setup-playwright-mcp.sh"
        # Run the setup script
        "$SCRIPT_DIR/setup-playwright-mcp.sh"
        
        # Check again if installation was successful
        if ! command -v playwright-mcp &> /dev/null; then
            echo "Error: Installation failed. Please run mcp/setup-playwright-mcp.sh manually." | tee -a "$LOG_FILE"
            exit 1
        fi
        
        echo "Installation successful!" | tee -a "$LOG_FILE"
    else
        echo "Error: Setup script not found at $SCRIPT_DIR/setup-playwright-mcp.sh" | tee -a "$LOG_FILE"
        exit 1
    fi
fi

# Set default log level if not provided
export FASTMCP_LOG_LEVEL="${FASTMCP_LOG_LEVEL:-ERROR}"

echo "Starting Microsoft Playwright MCP server..." | tee -a "$LOG_FILE"
echo "$(date): Playwright MCP server started" >> "$LOG_FILE"

# Execute the Playwright MCP server
playwright-mcp "$@"
exit_code=$?
# Log the exit code
echo "$(date): Playwright MCP server exited with code $exit_code" >> "$LOG_FILE"
exit $exit_code
