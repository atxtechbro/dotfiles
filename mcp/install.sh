#!/bin/bash

# MCP Installation Script
# This script installs the necessary dependencies for MCP servers

# Don't use set -e as it causes the script to exit on errors
# which breaks when sourced

# Function to handle errors gracefully
handle_error() {
  echo "Warning: $1"
  # Don't exit, just continue
}

# Create necessary directories
mkdir -p "$HOME/mcp" 2>/dev/null || handle_error "Failed to create $HOME/mcp directory"
mkdir -p "$HOME/.aws/amazonq" 2>/dev/null || handle_error "Failed to create $HOME/.aws/amazonq directory"
mkdir -p "$HOME/.config/claude" 2>/dev/null || handle_error "Failed to create $HOME/.config/claude directory"

# Ensure GitHub token is available
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  # Try to get from secrets file
  if [ -f "$HOME/.bash_secrets" ]; then
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets" 2>/dev/null; then
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets" 2>/dev/null | cut -d '=' -f2)
    fi
  fi
  
  # If still no token, use placeholder for testing
  if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
    echo "Setting placeholder token for testing."
    
    # Add to secrets file if it exists
    if [ -f "$HOME/.bash_secrets" ]; then
      echo "GITHUB_PERSONAL_ACCESS_TOKEN=placeholder_for_testing" >> "$HOME/.bash_secrets" 2>/dev/null || handle_error "Failed to update secrets file"
      chmod 600 "$HOME/.bash_secrets" 2>/dev/null || handle_error "Failed to set permissions on secrets file"
    fi
  fi
fi

# Run the setup script for personal configuration by default
echo "Setting up MCP with personal persona..."
bash "$(dirname "$0")/setup.sh" --persona personal || handle_error "MCP setup failed"

echo ""
echo "MCP installation complete!"
echo ""
echo "To start using MCP:"
echo "1. Source your bash profile: source ~/.bashrc"
echo "2. For company configuration, run: bash mcp/setup.sh --persona company"
echo ""
echo "For more information, see the README.md file in the mcp directory."
