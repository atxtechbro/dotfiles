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

# Clone the forked GitHub MCP server repository if it doesn't exist
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/github-mcp-server" ]; then
    echo "Cloning forked GitHub MCP server repository..."
    git clone https://github.com/atxtechbro/github-mcp-server.git "$CURRENT_SCRIPT_DIRECTORY/servers/github-mcp-server"
else
    echo "GitHub MCP server repository already exists, updating..."
    cd "$CURRENT_SCRIPT_DIRECTORY/servers/github-mcp-server"
    git pull
fi

# Fix potential go.mod issues
GO_MOD_FILE="$CURRENT_SCRIPT_DIRECTORY/servers/github-mcp-server/go.mod"
if [ -f "$GO_MOD_FILE" ]; then
    echo "Checking go.mod file for potential issues..."
    # Fix invalid Go version format (e.g., 1.23.7 -> 1.23)
    if grep -q "^go [0-9]\+\.[0-9]\+\.[0-9]\+" "$GO_MOD_FILE"; then
        echo "Found invalid Go version format in go.mod, fixing..."
        # Extract major and minor version, discard patch version
        sed -i 's/^go \([0-9]\+\.[0-9]\+\)\.[0-9]\+/go \1/' "$GO_MOD_FILE"
        echo "Fixed go.mod file"
    fi
fi

# Build the GitHub MCP server
echo "Building GitHub MCP server from source..."
cd "$CURRENT_SCRIPT_DIRECTORY/servers/github-mcp-server/cmd/github-mcp-server"

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