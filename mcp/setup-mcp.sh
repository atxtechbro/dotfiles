#!/bin/bash

# MCP Setup Script
# Creates the necessary directory structure for MCP server implementations
# Following the "spilled coffee principle" for reproducible environments

set -e

# Detect script location regardless of worktree
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Detect if running in a worktree
IS_WORKTREE=$(git rev-parse --is-inside-work-tree 2>/dev/null && echo "true" || echo "false")
MAIN_REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/ppv/pillars/dotfiles")
IS_WORKTREE_PATH=$(echo "$MAIN_REPO_PATH" | grep -q "pr-" && echo "true" || echo "false")

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

# Use dynamic paths based on whether we're in a worktree
if [[ "$IS_WORKTREE_PATH" == "true" ]]; then
  # In worktree - use current path for testing
  ln -sf "$REPO_ROOT/mcp/wrappers/git-mcp-wrapper.sh" ~/ppv/pipelines/bin/mcp-wrappers/git-mcp-wrapper.sh
else
  # In main repo or production - use standard path
  ln -sf ~/ppv/pillars/dotfiles/mcp/wrappers/git-mcp-wrapper.sh ~/ppv/pipelines/bin/mcp-wrappers/git-mcp-wrapper.sh
fi

# Create symlinks for utility scripts
mkdir -p ~/ppv/pipelines/bin

# Use dynamic paths based on whether we're in a worktree
if [[ "$IS_WORKTREE_PATH" == "true" ]]; then
  # In worktree - use current path for testing
  ln -sf "$REPO_ROOT/mcp/scripts/mcp-switch" ~/ppv/pipelines/bin/mcp-switch
  ln -sf "$REPO_ROOT/mcp/scripts/mcp-setup-implementation" ~/ppv/pipelines/bin/mcp-setup-implementation
  ln -sf "$REPO_ROOT/mcp/scripts/mcp-remove-implementation" ~/ppv/pipelines/bin/mcp-remove-implementation
  ln -sf "$REPO_ROOT/mcp/scripts/mcp-server" ~/ppv/pipelines/bin/mcp-server
else
  # In main repo or production - use standard path
  ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-switch ~/ppv/pipelines/bin/mcp-switch
  ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-setup-implementation ~/ppv/pipelines/bin/mcp-setup-implementation
  ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-remove-implementation ~/ppv/pipelines/bin/mcp-remove-implementation
  ln -sf ~/ppv/pillars/dotfiles/mcp/scripts/mcp-server ~/ppv/pipelines/bin/mcp-server
fi

echo "MCP server infrastructure setup complete!"
echo ""

# Display warning if in worktree mode
if [[ "$IS_WORKTREE_PATH" == "true" ]]; then
  echo "⚠️  Running in worktree mode - symlinks point to this worktree"
  echo "   These symlinks will need to be updated when merging to main"
  echo ""
fi

echo "To manage your MCP servers, use the following commands:"
echo "  mcp-server add git kzms https://github.com/atxtechbro/kzms-mcp-server-git.git"
echo "  mcp-server remove git"
echo "  mcp-server update git"
echo "  mcp-server list"
