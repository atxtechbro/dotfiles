#!/bin/bash

# =========================================================
# BRAVE SEARCH MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Brave Search MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The brave-search-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

echo "Setting up Brave Search MCP server..."

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
echo "Building Docker image for Brave Search MCP server..."
cd /tmp/mcp-servers && docker build -t mcp/brave-search -f src/brave-search/Dockerfile .

# Update .bash_secrets.example if needed
SECRETS_EXAMPLE="$REPO_ROOT/.bash_secrets.example"
if ! grep -q "BRAVE_SEARCH_API_KEY" "$SECRETS_EXAMPLE"; then
    echo "" >> "$SECRETS_EXAMPLE"
    echo "# ==== BRAVE SEARCH API CREDENTIALS ====" >> "$SECRETS_EXAMPLE"
    echo "# Get API key from: https://brave.com/search/api/" >> "$SECRETS_EXAMPLE"
    echo "# export BRAVE_SEARCH_API_KEY=\"your_api_key\"" >> "$SECRETS_EXAMPLE"
    
    echo "Updated .bash_secrets.example with Brave Search API key template"
fi

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

echo ""
echo "Setup complete! To use the Brave Search MCP server:"
echo "1. Add your Brave Search API key to ~/.bash_secrets:"
echo "   export BRAVE_SEARCH_API_KEY=\"your_api_key\""
echo "2. Restart your Amazon Q CLI or other MCP client"
echo ""
echo "The Brave Search MCP server provides these tools:"
echo "- brave_search: Search the web using Brave Search"
echo "- brave_suggest: Get search suggestions from Brave"
