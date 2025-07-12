#!/bin/bash

# =========================================================
# PLAYWRIGHT MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up the vendored Playwright MCP server
# This is a vendored copy maintained independently
# =========================================================

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install npm first."
    exit 1
fi

# Check if playwright-mcp directory exists
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/playwright-mcp" ]; then
    echo "Error: playwright-mcp directory not found at $CURRENT_SCRIPT_DIRECTORY/servers/playwright-mcp"
    echo "This should be part of the dotfiles repository now."
    exit 1
else
    echo "Found playwright-mcp directory in dotfiles..."
fi

# Set up the Node.js environment
echo "Setting up Node.js environment for Playwright MCP server..."
cd "$CURRENT_SCRIPT_DIRECTORY/servers/playwright-mcp"

# Install dependencies
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies from package.json..."
    npm install
else
    echo "Error: No package.json found. Installation cannot proceed."
    exit 1
fi

# Make the main script executable
if [ -f "index.js" ]; then
    chmod +x "index.js"
    echo "Made index.js executable"
else
    echo "Warning: Could not find index.js"
fi

echo "Playwright MCP server setup complete!"
echo "The wrapper script will now use the vendored version."