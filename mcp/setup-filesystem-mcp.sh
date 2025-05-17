#!/bin/bash

# =========================================================
# FILESYSTEM MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Filesystem MCP server
# This script builds the Docker image and updates the configuration
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The filesystem-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

echo "Setting up Filesystem MCP server..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first." >&2
    exit 1
fi

# Check if we're in the dotfiles repository
if [ ! -d "$(dirname "$0")/../.git" ]; then
    echo "Error: This script must be run from the dotfiles repository." >&2
    exit 1
fi

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Clone the MCP servers repository if it doesn't exist
if [ ! -d "/tmp/mcp-servers" ]; then
    echo "Cloning MCP servers repository..."
    git clone https://github.com/modelcontextprotocol/servers.git /tmp/mcp-servers
else
    echo "Updating MCP servers repository..."
    cd /tmp/mcp-servers && git pull
fi

# Build the Docker image
echo "Building Docker image for Filesystem MCP server..."
cd /tmp/mcp-servers && docker build -t mcp/filesystem -f src/filesystem/Dockerfile .

# Update mcp.json to include the Filesystem server
MCP_CONFIG="$REPO_ROOT/mcp/mcp.json"
if ! grep -q "\"filesystem\"" "$MCP_CONFIG"; then
    echo "Adding Filesystem configuration to mcp.json..."
    # Use a temporary file for the update
    TMP_FILE=$(mktemp)
    jq '.mcpServers += {"filesystem": {"command": "filesystem-mcp-wrapper.sh", "args": [], "env": {"FASTMCP_LOG_LEVEL": "ERROR"}}}' "$MCP_CONFIG" > "$TMP_FILE"
    mv "$TMP_FILE" "$MCP_CONFIG"
fi

echo ""
echo "Setup complete! To use the Filesystem MCP server:"
echo "1. Restart your Amazon Q CLI or other MCP client"
echo ""
echo "The Filesystem MCP server provides these tools:"
echo "- fs_read: Read files and directories"
echo "- fs_write: Create and modify files"
echo "- fs_delete: Delete files and directories"
echo "- fs_move: Move or rename files and directories"
echo "- fs_copy: Copy files and directories"
echo "- fs_list: List directory contents"
echo "- fs_search: Search for files and directories"
