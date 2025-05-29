#!/bin/bash

# =========================================================
# FILESYSTEM MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up the custom Filesystem MCP server from source
# This version modifies tool descriptions to de-emphasize
# the edit and write functions
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

# Check if TypeScript is installed globally
if ! command -v tsc &> /dev/null; then
    echo "TypeScript not found. Installing TypeScript..."
    npm install -g typescript
fi

# Create servers directory if it doesn't exist
mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers"

# Clone the dedicated filesystem-mcp-server repository
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server" ]; then
    echo "Cloning the custom filesystem-mcp-server repository..."
    git clone https://github.com/atxtechbro/filesystem-mcp-server.git "$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server"
else
    echo "Custom filesystem-mcp-server repository already exists locally, updating..."
    cd "$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server"
    git checkout main
    git pull origin main
fi

# Build the Filesystem MCP server
echo "Building custom Filesystem MCP server from source..."
cd "$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server"

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the TypeScript code
echo "Compiling TypeScript..."
npm run build

# Check if build was successful
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server/dist" ]; then
    echo "Error: Failed to build Filesystem MCP server"
    exit 1
else
    echo "Successfully built custom Filesystem MCP server"
fi

# Make the entry point executable
chmod +x "$CURRENT_SCRIPT_DIRECTORY/servers/filesystem-mcp-server/dist/index.js"
echo "Made entry point executable"

echo "Custom Filesystem MCP server setup complete!"
echo "This version de-emphasizes the edit and write functions in favor of other tools."
echo "The wrapper script will now use the built version with fallback to npx if needed."
