#!/bin/bash

# MCP Installation Script
# This script installs the necessary dependencies for MCP servers

set -e

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
  echo "Node.js is required but not installed."
  echo "Please install Node.js before continuing."
  exit 1
fi

# Check if NPM is installed
if ! command -v npm &> /dev/null; then
  echo "NPM is required but not installed."
  echo "Please install NPM before continuing."
  exit 1
fi

# Create symlink for bash aliases
echo "Setting up MCP bash aliases..."
if [ -f ~/.bash_aliases.mcp ]; then
  echo "Backing up existing ~/.bash_aliases.mcp to ~/.bash_aliases.mcp.bak"
  cp ~/.bash_aliases.mcp ~/.bash_aliases.mcp.bak
fi

ln -sf ~/ppv/pillars/dotfiles/.bash_aliases.mcp ~/.bash_aliases.mcp

# Run the setup script for personal configuration by default
echo "Setting up MCP with personal persona..."
./setup.sh --persona personal

echo ""
echo "MCP installation complete!"
echo ""
echo "To start using MCP:"
echo "1. Source your bash profile: source ~/.bashrc"
echo "2. Check MCP configuration: mcp-check"
echo "3. For company configuration, run: mcp-setup-company"
echo ""
echo "For more information, see the README.md file in the mcp directory."
