#!/bin/bash

# =========================================================
# SLACK MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Slack MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The slack-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

echo "Setting up Slack MCP server..."

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
echo "Building Docker image for Slack MCP server..."
cd /tmp/mcp-servers && docker build -t mcp/slack -f src/slack/Dockerfile .

# Update .bash_secrets.example if needed
SECRETS_EXAMPLE="$REPO_ROOT/.bash_secrets.example"
if ! grep -q "SLACK_BOT_TOKEN" "$SECRETS_EXAMPLE"; then
    echo "" >> "$SECRETS_EXAMPLE"
    echo "# ==== SLACK API CREDENTIALS ====" >> "$SECRETS_EXAMPLE"
    echo "# Create a Slack app and get a bot token: https://api.slack.com/apps" >> "$SECRETS_EXAMPLE"
    echo "# export SLACK_BOT_TOKEN=\"xoxb-your-token\"" >> "$SECRETS_EXAMPLE"
    
    echo "Updated .bash_secrets.example with Slack bot token template"
fi

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

echo ""
echo "Setup complete! To use the Slack MCP server:"
echo "1. Add your Slack bot token to ~/.bash_secrets:"
echo "   export SLACK_BOT_TOKEN=\"xoxb-your-token\""
echo "2. Restart your Amazon Q CLI or other MCP client"
echo ""
echo "The Slack MCP server provides these tools:"
echo "- slack_send_message: Send a message to a Slack channel or user"
echo "- slack_get_messages: Get messages from a Slack channel"
echo "- slack_list_channels: List available Slack channels"
echo "- slack_list_users: List users in your Slack workspace"
echo "- slack_search: Search for messages in Slack"
