#!/bin/bash
# Dotfiles Automated Setup Script
# Universal configuration for all environments

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting dotfiles setup...${NC}"

# Determine OS type
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
    if grep -q Microsoft /proc/version 2>/dev/null; then
        echo -e "${BLUE}Detected Windows Subsystem for Linux (WSL)${NC}"
        IS_WSL=true
    else
        IS_WSL=false
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
    IS_WSL=false
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${YELLOW}Detected OS: $OS_TYPE${NC}"

# Install essential packages based on OS
if [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v apt-get &> /dev/null; then
        echo -e "${YELLOW}Installing essential packages with apt...${NC}"
        sudo apt update
        sudo apt install -y git gh jq tmux curl wget
    elif command -v pacman &> /dev/null; then
        echo -e "${YELLOW}Installing essential packages with pacman...${NC}"
        sudo pacman -S --needed --noconfirm git github-cli jq tmux curl wget
    elif command -v dnf &> /dev/null; then
        echo -e "${YELLOW}Installing essential packages with dnf...${NC}"
        sudo dnf install -y git gh jq tmux curl wget
    else
        echo -e "${RED}Unsupported package manager. Please install git, gh, jq, tmux, curl, and wget manually.${NC}"
    fi
elif [[ "$OS_TYPE" == "macOS" ]]; then
    if command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing essential packages with Homebrew...${NC}"
        brew install git gh jq tmux curl wget
    else
        echo -e "${RED}Homebrew not found. Please install Homebrew first: https://brew.sh${NC}"
        exit 1
    fi
fi

# Handle WSL-specific setup
if [[ "$IS_WSL" == true ]]; then
    echo -e "${YELLOW}Setting up WSL-specific configuration...${NC}"
    if [[ -d "/mnt/c/dotfiles" ]]; then
        echo -e "${BLUE}Found dotfiles in Windows filesystem, creating symlink...${NC}"
        ln -sf /mnt/c/dotfiles ~/dotfiles
    fi
fi

# Clone dotfiles repository if it doesn't exist and we're not in WSL
if [[ ! -d ~/dotfiles && "$IS_WSL" == false ]]; then
    echo -e "${YELLOW}Cloning dotfiles repository...${NC}"
    git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
    echo -e "${GREEN}Dotfiles repository cloned successfully!${NC}"
elif [[ -d ~/dotfiles ]]; then
    echo -e "${BLUE}Dotfiles repository already exists, updating...${NC}"
    cd ~/dotfiles
    git pull
fi

# Create necessary directories
echo -e "${YELLOW}Creating config directories...${NC}"
mkdir -p ~/.config/nvim

# Add a note about Neovim installation
echo -e "${BLUE}Note: Neovim should be installed from source as per README instructions${NC}"

# Create symlinks
echo -e "${YELLOW}Creating symlinks for configuration files...${NC}"
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/.bash_exports ~/.bash_exports
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# Create secrets file from template
if [[ -f ~/dotfiles/.bash_secrets.example && ! -f ~/.bash_secrets ]]; then
    echo -e "${YELLOW}Creating secrets file from template...${NC}"
    cp ~/dotfiles/.bash_secrets.example ~/.bash_secrets
    chmod 600 ~/.bash_secrets
    echo -e "${BLUE}Created ~/.bash_secrets from template. Edit it to add your secrets.${NC}"
fi

# Apply bash configuration
echo -e "${YELLOW}Applying bash configuration...${NC}"
# shellcheck disable=SC1090
source ~/.bashrc 2>/dev/null || true

echo -e "${GREEN}Dotfiles setup complete!${NC}"
echo -e "${YELLOW}Your development environment is now configured and ready to use.${NC}"
echo -e "${BLUE}Enjoy your personalized setup!${NC}"
