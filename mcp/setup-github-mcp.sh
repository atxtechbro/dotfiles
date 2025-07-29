#!/bin/bash

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Source the Go installation script
DOTFILES_ROOT="$(cd "$CURRENT_SCRIPT_DIRECTORY/.." && pwd)"
source "$DOTFILES_ROOT/utils/install-go.sh"

# Ensure Go is installed
if ! ensure_go_installed; then
    echo "Error: Go installation failed. Cannot continue with GitHub MCP server setup."
    exit 1
fi

echo "Go installation verified. Proceeding with GitHub MCP server setup..."

# Create servers directory if it doesn't exist
mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers"

# GitHub MCP server is now in-house at mcp/servers/github-mcp-server
GITHUB_MCP_DIR="$CURRENT_SCRIPT_DIRECTORY/servers/github-mcp-server"

# Verify the in-house GitHub MCP server exists
if [ ! -d "$GITHUB_MCP_DIR" ]; then
    echo "Error: GitHub MCP server directory not found at $GITHUB_MCP_DIR"
    echo "The GitHub MCP server is now managed in-house within the dotfiles repository."
    exit 1
fi

# Build the GitHub MCP server
echo "Building GitHub MCP server from in-house source..."
cd "$GITHUB_MCP_DIR/cmd/github-mcp-server"

# Remove existing binary if it exists to ensure a fresh build
if [ -f "$CURRENT_SCRIPT_DIRECTORY/servers/github" ]; then
    echo "Removing existing binary for clean rebuild..."
    rm "$CURRENT_SCRIPT_DIRECTORY/servers/github"
fi

# Build new binary
echo "Compiling new binary..."
go build -o "$CURRENT_SCRIPT_DIRECTORY/servers/github"

# Check if build was successful
if [ ! -f "$CURRENT_SCRIPT_DIRECTORY/servers/github" ]; then
    echo "Error: Failed to build GitHub MCP server"
    exit 1
else
    echo "Successfully built new GitHub MCP server binary"
fi

# Make the binary executable
chmod +x "$CURRENT_SCRIPT_DIRECTORY/servers/github"
echo "Made binary executable"

echo "GitHub MCP server setup complete!"
echo "The server will use your GitHub CLI authentication token."
echo "Make sure you're logged in with 'gh auth login' before using the GitHub MCP server."