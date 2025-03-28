#!/bin/bash

# Main script to install all CLI tools
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create necessary directories
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config"

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Define tools to install
TOOLS=(
    "jira-cli"
    # Add more tools here as they're added
)

TOTAL_TOOLS=${#TOOLS[@]}
CURRENT_TOOL=0

# Install individual tools
for tool in "${TOOLS[@]}"; do
    CURRENT_TOOL=$((CURRENT_TOOL + 1))
    echo "Installing tool ($CURRENT_TOOL/$TOTAL_TOOLS): $tool"
    source "$DOTFILES_DIR/install/$tool.sh"
done

echo "All $TOTAL_TOOLS/$TOTAL_TOOLS tools installed successfully!"
