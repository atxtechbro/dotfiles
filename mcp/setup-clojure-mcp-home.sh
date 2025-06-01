#!/bin/bash
# setup-clojure-mcp-home.sh - Set up Clojure MCP in the home directory
# This script follows the "Spilled Coffee Principle" and "Versioning Mindset"

set -e

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"
HOME_DIR="$HOME"

echo "Setting up Clojure MCP in the home directory..."

# Check if source deps.edn exists
if [ ! -f "$DOTFILES_DIR/deps.edn" ]; then
  echo "Error: Source deps.edn not found in $DOTFILES_DIR"
  exit 1
fi

# Copy deps.edn to home directory
echo "Copying deps.edn to home directory..."
cp "$DOTFILES_DIR/deps.edn" "$HOME_DIR/deps.edn"

# Create symlink for clojure-mcp-wrapper.sh in home directory
echo "Creating symlink for clojure-mcp-wrapper.sh in home directory..."
ln -sf "$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh" "$HOME_DIR/clojure-mcp-wrapper.sh"

echo "Clojure MCP setup in home directory complete!"
echo "You can now run Clojure MCP from your home directory with:"
echo "cd ~ && ./clojure-mcp-wrapper.sh"
