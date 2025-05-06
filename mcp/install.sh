#!/bin/bash

# MCP Installation Script
# This script installs the necessary dependencies for MCP servers

set -e

# Run the setup script for personal configuration by default
echo "Setting up MCP with personal persona..."
bash "$(dirname "$0")/setup.sh" --persona personal

echo ""
echo "MCP installation complete!"
echo ""
echo "To start using MCP:"
echo "1. Source your bash profile: source ~/.bashrc"
echo "2. For company configuration, run: bash mcp/setup.sh --persona company"
echo ""
echo "For more information, see the README.md file in the mcp directory."
