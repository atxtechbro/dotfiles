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

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed. Please install pip3 first."
    exit 1
fi

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

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "Installing Python dependencies..."
    pip3 install -r requirements.txt --user
else
    echo "Warning: No requirements.txt found. Skipping dependency installation."
fi

# Check if setup.py exists and install the package
if [ -f "setup.py" ]; then
    echo "Installing the Git MCP server package..."
    pip3 install -e . --user
fi

# Make the entry point executable if it exists
if [ -f "git_mcp_server.py" ]; then
    chmod +x "git_mcp_server.py"
    echo "Made entry point executable"
elif [ -f "main.py" ]; then
    chmod +x "main.py"
    echo "Made entry point executable"
elif [ -f "app.py" ]; then
    chmod +x "app.py"
    echo "Made entry point executable"
else
    echo "Warning: Could not identify the main Python script. Please check the repository structure."
fi

echo "Git MCP server setup complete!"
echo "The wrapper script will now use the built version exclusively."