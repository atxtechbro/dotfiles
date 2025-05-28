#!/bin/bash
#
# setup-mcp-shell.sh - Sets up the mcp-shell server for use with Amazon Q CLI
#
# This script registers the mcp-shell server with Amazon Q CLI.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_SCRIPT="$SCRIPT_DIR/mcp-shell-wrapper.sh"

# Check if Amazon Q CLI is installed
if ! command -v q &> /dev/null; then
    echo "Error: Amazon Q CLI not found"
    echo "Please install Amazon Q CLI first"
    exit 1
fi

# Register the MCP server with Amazon Q CLI
echo "Registering mcp-shell server with Amazon Q CLI..."
q mcp register --name mcp-shell --path "$WRAPPER_SCRIPT"

echo "MCP shell server registered successfully!"
echo "You can now use it with Amazon Q CLI by running: q chat"