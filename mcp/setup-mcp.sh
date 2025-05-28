#!/bin/bash

# MCP Setup Script
# Creates the necessary directory structure for MCP server implementations
# Following the "spilled coffee principle" for reproducible environments

set -e

echo "Setting up MCP server infrastructure..."

# Create directories for MCP server implementations
mkdir -p ~/.local/share/mcp-servers/{python,typescript,binary}
mkdir -p ~/.local/share/mcp-servers/python/git/{kzms,cyanheads}
mkdir -p ~/.local/share/mcp-servers/typescript/git/{cyanheads}

# Create directories for virtual environments
mkdir -p ~/ppv/pipelines/venvs/mcp-servers

# Create directories for configuration
mkdir -p ~/.config/mcp/active-implementations

# Create symlinks for wrapper scripts
mkdir -p ~/ppv/pipelines/bin/mcp-wrappers
ln -sf ~/ppv/pillars/dotfiles/mcp/wrappers/git-mcp-wrapper.sh ~/ppv/pipelines/bin/mcp-wrappers/git-mcp-wrapper.sh

# Create symlinks for utility scripts
mkdir -p ~/ppv/pipelines/bin
ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-switch ~/ppv/pipelines/bin/mcp-switch
ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-setup-implementation ~/ppv/pipelines/bin/mcp-setup-implementation
ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-remove-implementation ~/ppv/pipelines/bin/mcp-remove-implementation

echo "MCP server infrastructure setup complete!"
echo ""
echo "To manage your MCP servers, use the following commands:"
echo "  mcp-server add git kzms https://github.com/atxtechbro/kzms-mcp-server-git.git"
echo "  mcp-server remove git"
echo "  mcp-server update git"
echo "  mcp-server list"
