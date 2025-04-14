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

# Check for essential tools
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Required command '$1' not found.${NC}"
        echo -e "${YELLOW}Please install it using your package manager before running this script.${NC}"
        echo -e "${BLUE}See the README.md for OS-specific installation instructions.${NC}"
        return 1
    fi
    return 0
}

# Check for essential commands
essential_commands=("git" "curl")
missing_commands=false

for cmd in "${essential_commands[@]}"; do
    if ! check_command "$cmd"; then
        missing_commands=true
    fi
done

if [[ "$missing_commands" == true ]]; then
    echo -e "${RED}Please install the missing commands and run this script again.${NC}"
    exit 1
fi

# Determine OS type (for informational purposes only)
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
    echo -e "${YELLOW}Unrecognized OS: $OSTYPE. Proceeding anyway...${NC}"
    OS_TYPE="Unknown"
    IS_WSL=false
fi

echo -e "${YELLOW}Detected OS: $OS_TYPE${NC}"

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

# Check if this is running on Arch Linux and offer Arch-specific setup
if command -v pacman &>/dev/null; then
    echo -e "${YELLOW}Detected Arch Linux!${NC}"
    
    # Check if Arch Linux setup script exists
    if [[ -f ~/dotfiles/arch-linux/setup.sh ]]; then
        echo -e "${YELLOW}Running Arch Linux specific setup...${NC}"
        bash ~/dotfiles/arch-linux/setup.sh
    else
        echo -e "${YELLOW}No Arch Linux setup script found. Skipping Arch-specific setup.${NC}"
    fi
fi

# Check if this is a Raspberry Pi and run Pi-specific setup if needed
if grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo -e "${YELLOW}Detected Raspberry Pi hardware!${NC}"
    
    # Check if Raspberry Pi setup script exists
    if [[ -f ~/dotfiles/raspberry-pi/setup.sh ]]; then
        echo -e "${YELLOW}Running Raspberry Pi specific setup...${NC}"
        bash ~/dotfiles/raspberry-pi/setup.sh
    else
        echo -e "${YELLOW}No Raspberry Pi setup script found. Skipping Pi-specific setup.${NC}"
    fi
fi

echo -e "${GREEN}Dotfiles setup complete!${NC}"
echo -e "${YELLOW}Your development environment is now configured and ready to use.${NC}"
echo -e "${BLUE}Enjoy your personalized setup!${NC}"

# Amazon Q setup and management
if command -v q >/dev/null 2>&1; then
  echo -e "${YELLOW}Amazon Q is installed. Checking for updates...${NC}"
  
  # Check if update is available
  UPDATE_CHECK=$(q update 2>&1 | grep "A new version of q is available:" || echo "")
  
  if [ -n "$UPDATE_CHECK" ]; then
    echo -e "${YELLOW}Amazon Q update available. Installing...${NC}"
    
    # Determine architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
      echo -e "${BLUE}Detected x86-64 architecture${NC}"
      curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip" -o "q.zip"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
      echo -e "${BLUE}Detected ARM architecture${NC}"
      curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-aarch64-linux.zip" -o "q.zip"
    else
      echo -e "${RED}Unsupported architecture: $ARCH${NC}"
      echo -e "${RED}Cannot update Amazon Q automatically${NC}"
    fi
    
    # Install if zip was downloaded
    if [ -f "q.zip" ]; then
      unzip -o q.zip
      ./q/install.sh
      rm -rf q.zip q/
      echo -e "${GREEN}Amazon Q updated successfully${NC}"
    fi
  else
    echo -e "${GREEN}Amazon Q is up to date${NC}"
  fi
  
  # Disable telemetry if not already disabled
  TELEMETRY_STATUS=$(q telemetry status 2>/dev/null | grep -i "disabled" || echo "")
  if [ -z "$TELEMETRY_STATUS" ]; then
    echo -e "${YELLOW}Disabling Amazon Q telemetry...${NC}"
    q telemetry disable
    echo -e "${GREEN}Amazon Q telemetry disabled${NC}"
  else
    echo -e "${BLUE}Amazon Q telemetry already disabled${NC}"
  fi
fi


if ! command -v uv >/dev/null 2>&1; then
  echo "📦 Installing uv..."
  curl -Ls https://astral.sh/uv/install.sh | sh
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

