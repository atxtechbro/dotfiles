#!/bin/bash

# =========================================================
# ATLASSIAN MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script that prepares your environment
# This script installs dependencies, creates directories, and
# guides you through setting up your Atlassian credentials
# 
# RELATIONSHIP: This is the one-time setup script that you run
# manually. It prepares your environment for the atlassian-mcp-wrapper.sh
# script, which is the runtime component that gets executed by the
# MCP system during normal operation.
# =========================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_TEMPLATE="${SCRIPT_DIR}/../.bash_secrets.example"
USER_SECRETS="${HOME}/.bash_secrets"

# Install mcp-atlassian if not already installed
echo "Checking for mcp-atlassian..."
if ! command -v uvx &> /dev/null; then
  echo "Installing uv package manager..."
  curl -fsSL https://astral.sh/uv/install.sh | sh
fi

echo "Installing mcp-atlassian..."
uvx install mcp-atlassian

# Create directories if they don't exist
mkdir -p "${SCRIPT_DIR}/servers"

# Check if secrets file exists and contains Atlassian credentials
if [ -f "$USER_SECRETS" ]; then
  echo "Checking for Atlassian credentials in ~/.bash_secrets..."
  
  # Source the secrets file to check for variables
  source "$USER_SECRETS"
  
  # Check if all required variables are set
  if [ -z "$ATLASSIAN_CONFLUENCE_URL" ] || [ -z "$ATLASSIAN_CONFLUENCE_USERNAME" ] || [ -z "$ATLASSIAN_CONFLUENCE_API_TOKEN" ] || \
     [ -z "$ATLASSIAN_JIRA_URL" ] || [ -z "$ATLASSIAN_JIRA_USERNAME" ] || [ -z "$ATLASSIAN_JIRA_API_TOKEN" ]; then
    echo "Atlassian credentials not found in ~/.bash_secrets"
    echo "Please add the following variables to your ~/.bash_secrets file:"
    echo "  export ATLASSIAN_CONFLUENCE_URL=\"https://your-domain.atlassian.net/wiki\""
    echo "  export ATLASSIAN_CONFLUENCE_USERNAME=\"your.email@domain.com\""
    echo "  export ATLASSIAN_CONFLUENCE_API_TOKEN=\"your_api_token\""
    echo "  export ATLASSIAN_JIRA_URL=\"https://your-domain.atlassian.net\""
    echo "  export ATLASSIAN_JIRA_USERNAME=\"your.email@domain.com\""
    echo "  export ATLASSIAN_JIRA_API_TOKEN=\"your_api_token\""
    echo ""
    echo "You can get API tokens from: https://id.atlassian.com/manage-profile/security/api-tokens"
  else
    echo "Atlassian credentials found in ~/.bash_secrets"
  fi
else
  echo "~/.bash_secrets file not found"
  echo "Creating ~/.bash_secrets from template..."
  cp "$SECRETS_TEMPLATE" "$USER_SECRETS"
  chmod 600 "$USER_SECRETS"
  echo "Please edit ~/.bash_secrets to add your Atlassian credentials"
fi

# Make wrapper script executable
chmod +x "${SCRIPT_DIR}/servers/atlassian-mcp-wrapper.sh"

echo "Setup complete!"
echo "To use the Atlassian MCP integration:"
echo "1. Make sure your credentials are in ~/.bash_secrets"
echo "2. Restart Amazon Q CLI or Claude Desktop"
echo ""
echo "You can test the integration with: uvx @modelcontextprotocol/inspector ${SCRIPT_DIR}/servers/atlassian-mcp-wrapper.sh"
