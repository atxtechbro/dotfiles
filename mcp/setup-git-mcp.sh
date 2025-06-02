#!/bin/bash

# =========================================================
# GIT MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up the Git MCP server from source
# This allows customization of the server code to fix issues
# and add features like git worktree support
# =========================================================
# IMPORTANT: This script uses our own Python-based Git MCP server repository
# =========================================================

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Using uv for package management

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Create servers directory if it doesn't exist
mkdir -p "$CURRENT_SCRIPT_DIRECTORY/servers"

# Clone our Git MCP server repository if it doesn't exist locally
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server" ]; then
    echo "Cloning our Python-based Git MCP server repository..."
    git clone https://github.com/atxtechbro/git-mcp-server.git "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone the repository. Please check if the repository exists and is accessible."
        exit 1
    fi
else
    echo "Our Git MCP server repository already exists locally, updating..."
    cd "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"
    git pull || echo "Warning: Unable to pull updates, continuing with existing code"
fi

# Set up the Python environment
echo "Setting up Python environment for Git MCP server..."
cd "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"

# Install using pyproject.toml with uv
if [ -f "pyproject.toml" ]; then
    # Create and use a virtual environment
    echo "Creating virtual environment..."
    uv venv .venv
    source .venv/bin/activate
    
    echo "Installing Python dependencies from pyproject.toml..."
    uv pip install -e .
else
    echo "Warning: No pyproject.toml found. Installation may be incomplete."
fi

# Make the main module executable
MAIN_MODULE_PATH="$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server/src/mcp_server_git/__main__.py"
if [ -f "$MAIN_MODULE_PATH" ]; then
    chmod +x "$MAIN_MODULE_PATH"
    echo "Made main module executable: $MAIN_MODULE_PATH"
    
    # Create a symlink to make it easier to run
    ln -sf "$MAIN_MODULE_PATH" "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server/git_mcp_server.py"
    chmod +x "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server/git_mcp_server.py"
    echo "Created executable symlink: git_mcp_server.py"
else
    echo "Warning: Could not find the main module at $MAIN_MODULE_PATH"
fi

echo "Git MCP server setup complete!"
echo "The wrapper script will now use the built version exclusively."
