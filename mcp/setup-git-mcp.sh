#!/bin/bash

# =========================================================
# GIT MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up the Git MCP server from local source
# The git-mcp-server is now part of the dotfiles repository
# for unified management and faster iteration
# =========================================================

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed. Please install uv first."
    exit 1
fi

# Check if git-mcp-server directory exists (now part of dotfiles)
if [ ! -d "$CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server" ]; then
    echo "Error: git-mcp-server directory not found at $CURRENT_SCRIPT_DIRECTORY/servers/git-mcp-server"
    echo "This should be part of the dotfiles repository now."
    exit 1
else
    echo "Found git-mcp-server directory in dotfiles..."
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
echo "The wrapper script will now use the local version exclusively."
