#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Google Drive MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The gdrive-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

echo "Setting up Google Drive MCP server..."

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
echo "Building Docker image for Google Drive MCP server..."
cd /tmp/mcp-servers && docker build -t mcp/gdrive -f src/gdrive/Dockerfile .

# Update .bash_secrets.example if needed
SECRETS_EXAMPLE="$REPO_ROOT/.bash_secrets.example"
if ! grep -q "GOOGLE_DRIVE_CLIENT_ID" "$SECRETS_EXAMPLE"; then
    echo "" >> "$SECRETS_EXAMPLE"
    echo "# ==== GOOGLE DRIVE API CREDENTIALS ====" >> "$SECRETS_EXAMPLE"
    echo "# Create credentials at: https://console.cloud.google.com/apis/credentials" >> "$SECRETS_EXAMPLE"
    echo "# export GOOGLE_DRIVE_CLIENT_ID=\"your_client_id\"" >> "$SECRETS_EXAMPLE"
    echo "# export GOOGLE_DRIVE_CLIENT_SECRET=\"your_client_secret\"" >> "$SECRETS_EXAMPLE"
    echo "# export GOOGLE_DRIVE_REFRESH_TOKEN=\"your_refresh_token\"" >> "$SECRETS_EXAMPLE"
    
    echo "Updated .bash_secrets.example with Google Drive API credentials template"
fi

# Update mcp.json to include the Google Drive server
MCP_CONFIG="$REPO_ROOT/mcp/mcp.json"
if ! grep -q "\"gdrive\"" "$MCP_CONFIG"; then
    echo "Adding Google Drive configuration to mcp.json..."
    # Use a temporary file for the update
    TMP_FILE=$(mktemp)
    jq '.mcpServers += {"gdrive": {"command": "gdrive-mcp-wrapper.sh", "args": [], "env": {"FASTMCP_LOG_LEVEL": "ERROR"}}}' "$MCP_CONFIG" > "$TMP_FILE"
    mv "$TMP_FILE" "$MCP_CONFIG"
fi

echo ""
echo "Setup complete! To use the Google Drive MCP server:"
echo "1. Add your Google Drive API credentials to ~/.bash_secrets:"
echo "   export GOOGLE_DRIVE_CLIENT_ID=\"your_client_id\""
echo "   export GOOGLE_DRIVE_CLIENT_SECRET=\"your_client_secret\""
echo "   export GOOGLE_DRIVE_REFRESH_TOKEN=\"your_refresh_token\""
echo "2. Restart your Amazon Q CLI or other MCP client"
echo ""
echo "The Google Drive MCP server provides these tools:"
echo "- gdrive_list: List files and folders in Google Drive"
echo "- gdrive_get: Download a file from Google Drive"
echo "- gdrive_create: Create a new file in Google Drive"
echo "- gdrive_update: Update an existing file in Google Drive"
echo "- gdrive_delete: Delete a file or folder in Google Drive"
echo "- gdrive_search: Search for files in Google Drive"
