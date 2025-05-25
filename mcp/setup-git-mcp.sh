#!/bin/bash

# =========================================================
# GIT MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up the Git MCP server from source
# This allows customization of the server code to fix issues
# and add features like git worktree support
# =========================================================
# IMPORTANT: This script assumes you've already forked the
# cyanheads/git-mcp-server repository to your GitHub account
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

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Create servers directory if it doesn't exist
mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers"

# Clone your existing fork of the Git MCP server repository if it doesn't exist locally
# Note: This assumes you've already forked https://github.com/cyanheads/git-mcp-server to
# https://github.com/atxtechbro/git-mcp-server on GitHub
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server" ]; then
    echo "Cloning your existing fork of the Git MCP server repository..."
    echo "Note: This does NOT create a new fork on GitHub, just clones your existing one"
    git clone https://github.com/atxtechbro/git-mcp-server.git "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"
else
    echo "Your forked Git MCP server repository already exists locally, updating..."
    cd "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"
    git pull
fi

# Build the Git MCP server
echo "Building Git MCP server from source..."
cd "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the TypeScript code
echo "Compiling TypeScript..."
npm run build

# Check if build was successful
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server/dist" ]; then
    echo "Error: Failed to build Git MCP server"
    exit 1
else
    echo "Successfully built Git MCP server"
fi

# Make the entry point executable
chmod +x "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server/dist/index.js"
echo "Made entry point executable"

echo "Git MCP server setup complete!"
echo "The wrapper script will now use the built version with fallback to the original implementation if needed."
