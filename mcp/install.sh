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

# Run the setup script for personal configuration by default
echo "Setting up MCP with personal persona..."
./setup.sh --persona personal

echo ""
echo "MCP installation complete!"
echo ""
echo "To start using MCP:"
echo "1. Source your bash profile: source ~/.bashrc"
echo "2. For company configuration, run: ./setup.sh --persona company"
echo ""
echo "For more information, see the README.md file in the mcp directory."
