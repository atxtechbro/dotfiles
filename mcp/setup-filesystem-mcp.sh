#!/bin/bash

# =========================================================
# FILESYSTEM MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up the Filesystem MCP server from source
# This allows customization of the server code to fix issues
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

# Clone the forked MCP servers repository if it doesn't exist
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/mcp-servers" ]; then
    echo "Cloning forked MCP servers repository..."
    git clone https://github.com/atxtechbro/mcp-servers.git "$CURRENT_SCRIPT_DIRECTORY/servers/mcp-servers"
else
    echo "MCP servers repository already exists, updating..."
    cd "$CURRENT_SCRIPT_DIRECTORY/servers/mcp-servers"
    git pull
fi

# Build the Filesystem MCP server
echo "Building Filesystem MCP server from source..."
cd "$CURRENT_SCRIPT_DIRECTORY/servers/mcp-servers/src/filesystem"

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the TypeScript code
echo "Compiling TypeScript..."
npm run build

# Check if build was successful
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/mcp-servers/src/filesystem/dist" ]; then
    echo "Error: Failed to build Filesystem MCP server"
    exit 1
else
    echo "Successfully built Filesystem MCP server"
fi

# Make the entry point executable
chmod +x "$CURRENT_SCRIPT_DIRECTORY/servers/mcp-servers/src/filesystem/dist/index.js"
echo "Made entry point executable"

echo "Filesystem MCP server setup complete!"
echo "The wrapper script will now use the built version with fallback to npx if needed."
