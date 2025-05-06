#!/bin/bash

# Dotfiles setup script
# This script sets up symlinks for all dotfiles in this repository

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to create symlink with backup
create_symlink() {
  local source="$1"
  local target="$2"
  
  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$target")"
  
  # Backup existing file/directory if it exists and is not a symlink to our dotfiles
  if [ -e "$target" ] && [ ! -L "$target" -o "$(readlink "$target")" != "$source" ]; then
    echo "Backing up $target to $BACKUP_DIR/$(basename "$target")"
    mv "$target" "$BACKUP_DIR/$(basename "$target")"
  fi
  
  # Create symlink
  ln -sf "$source" "$target"
  echo "Created symlink: $target -> $source"
}

# Setup bash aliases
for alias_file in "$DOTFILES_DIR"/.bash_aliases.*; do
  if [ -f "$alias_file" ]; then
    create_symlink "$alias_file" "$HOME/$(basename "$alias_file")"
  fi
done

# Setup bash configuration
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

# Setup tmux configuration
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Setup git configuration
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
for git_config in "$DOTFILES_DIR"/.gitconfig.*; do
  if [ -f "$git_config" ]; then
    create_symlink "$git_config" "$HOME/$(basename "$git_config")"
  fi
done

# Setup vim/neovim configuration
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Setup MCP configuration
echo "Setting up MCP configuration..."
if [ -x "$DOTFILES_DIR/mcp/install.sh" ]; then
  (cd "$DOTFILES_DIR/mcp" && ./install.sh)
else
  echo "MCP installation script not found or not executable"
fi

# Create secrets file from template if it doesn't exist
if [ ! -f "$HOME/.bash_secrets" ] && [ -f "$DOTFILES_DIR/.bash_secrets.example" ]; then
  echo "Creating ~/.bash_secrets from template"
  cp "$DOTFILES_DIR/.bash_secrets.example" "$HOME/.bash_secrets"
  chmod 600 "$HOME/.bash_secrets"
fi

echo ""
echo "Dotfiles setup complete!"
echo ""
echo "To apply changes immediately, run:"
echo "  source ~/.bashrc"
echo ""
echo "Backup of original files (if any) stored in: $BACKUP_DIR"
