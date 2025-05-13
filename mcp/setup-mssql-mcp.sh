#!/bin/bash

# =========================================================
# MSSQL MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script that prepares your environment
# This script installs dependencies, creates directories, and
# guides you through setting up your MSSQL credentials
# 
# RELATIONSHIP: This is the one-time setup script that you run
# manually. It prepares your environment for the mssql-mcp-wrapper.sh
# script, which is the runtime component that gets executed by the
# MCP system during normal operation.
# =========================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_TEMPLATE="${SCRIPT_DIR}/../.bash_secrets.example"
USER_SECRETS="${HOME}/.bash_secrets"

# Install mssql-mcp-server if not already installed
echo "Checking for mssql-mcp-server..."
if ! command -v uvx &> /dev/null; then
  echo "Installing uv package manager..."
  curl -fsSL https://astral.sh/uv/install.sh | sh
fi

echo "Installing mssql-mcp-server..."
uvx install mssql-mcp-server

# Create directories if they don't exist
mkdir -p "${SCRIPT_DIR}/servers"

# Check if secrets file exists and contains MSSQL credentials
if [ -f "$USER_SECRETS" ]; then
  echo "Checking for MSSQL credentials in ~/.bash_secrets..."
  
  # Source the secrets file to check for variables
  source "$USER_SECRETS"
  
  # Check if all required variables are set
  if [ -z "$MSSQL_DRIVER" ] || [ -z "$MSSQL_HOST" ] || [ -z "$MSSQL_USER" ] || \
     [ -z "$MSSQL_PASSWORD" ] || [ -z "$MSSQL_DATABASE" ]; then
    echo "MSSQL credentials not found in ~/.bash_secrets"
    echo "Please add the following variables to your ~/.bash_secrets file:"
    echo "  export MSSQL_DRIVER=\"your_mssql_driver\"" 
    echo "  export MSSQL_HOST=\"localhost\""
    echo "  export MSSQL_USER=\"your_username\""
    echo "  export MSSQL_PASSWORD=\"your_password\""
    echo "  export MSSQL_DATABASE=\"your_database\""
    echo "  export MSSQL_TRUST_SERVER_CERT=\"yes\"  # Optional"
    echo "  export MSSQL_TRUSTED_CONNECTION=\"no\"  # Optional"
    echo ""
    echo "For security best practices:"
    echo "- Use a dedicated MSSQL user with minimal privileges"
    echo "- Never use root credentials or full administrative accounts"
    echo "- Restrict database access to only necessary operations"
  else
    echo "MSSQL credentials found in ~/.bash_secrets"
  fi
else
  echo "~/.bash_secrets file not found"
  echo "Creating ~/.bash_secrets from template..."
  cp "$SECRETS_TEMPLATE" "$USER_SECRETS"
  chmod 600 "$USER_SECRETS"
  echo "Please edit ~/.bash_secrets to add your MSSQL credentials"
fi

# Make wrapper script executable
chmod +x "${SCRIPT_DIR}/servers/mssql-mcp-wrapper.sh"

echo "Setup complete!"
echo "To use the MSSQL MCP integration:"
echo "1. Make sure your credentials are in ~/.bash_secrets"
echo "2. Restart Amazon Q CLI or Claude Desktop"
echo ""
echo "You can test the integration with: uvx @modelcontextprotocol/inspector ${SCRIPT_DIR}/servers/mssql-mcp-wrapper.sh"
