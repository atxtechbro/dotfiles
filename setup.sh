#!/bin/bash

# Main setup script for dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up dotfiles..."

# Create symlinks for configuration files
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$DOTFILES_DIR/.bash_exports" "$HOME/.bash_exports"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Install CLI tools
source "$DOTFILES_DIR/install/install-tools.sh"

# Source the bash configuration
source "$HOME/.bashrc"

echo "Dotfiles setup complete!"
