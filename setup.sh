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

DOT_DEN="$HOME/ppv/pillars/dotfiles"

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
        ln -sf /mnt/c/dotfiles "$DOT_DEN"
    fi
fi

# Clone dotfiles repository if it doesn't exist and we're not in WSL
if [[ ! -d "$DOT_DEN" && "$IS_WSL" == false ]]; then
    echo -e "${YELLOW}Cloning dotfiles repository...${NC}"
    mkdir -p "$(dirname "$DOT_DEN")"
    git clone https://github.com/atxtechbro/dotfiles.git "$DOT_DEN"
    echo -e "${GREEN}Dotfiles repository cloned successfully!${NC}"
elif [[ -d "$DOT_DEN" ]]; then
    echo -e "${BLUE}Dotfiles repository already exists at $DOT_DEN${NC}"
    cd "$DOT_DEN"
fi

### Set up Neovim
echo -e "${YELLOW}Setting up Neovim...${NC}"

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${YELLOW}Neovim not found. Installing...${NC}"
    
    # Download latest Neovim release
    NVIM_TMP_DIR=$(mktemp -d)
    NVIM_RELEASE="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    
    echo -e "${BLUE}Downloading Neovim from: ${NVIM_RELEASE}${NC}"
    curl -L -o "${NVIM_TMP_DIR}/nvim.tar.gz" "${NVIM_RELEASE}"
    
    # Install Neovim
    echo -e "${BLUE}Installing Neovim to /opt...${NC}"
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf "${NVIM_TMP_DIR}/nvim.tar.gz"
    
    # Clean up
    rm -rf "${NVIM_TMP_DIR}"
    
    # Add to PATH if not already there
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.bashrc; then
        echo -e "${BLUE}Adding Neovim to PATH in ~/.bashrc...${NC}"
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
        export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    fi
    
    echo -e "${GREEN}Neovim installed successfully!${NC}"
fi

# Link Neovim configuration
echo -e "${YELLOW}Linking Neovim configuration...${NC}"
rm -rf ~/.config/nvim
ln -sfn "$DOT_DEN/nvim" ~/.config/nvim

# Install Neovim dependencies
echo -e "${YELLOW}Installing Neovim dependencies...${NC}"

# Run LSP install script
if [ -f "$DOT_DEN/nvim/lsp-install.sh" ]; then
    echo -e "${BLUE}Running LSP installation script...${NC}"
    "$DOT_DEN/nvim/lsp-install.sh"
fi

# Run Python debug install script
if [ -f "$DOT_DEN/nvim/python-debug-install.sh" ]; then
    echo -e "${BLUE}Running Python debugging tools installation script...${NC}"
    "$DOT_DEN/nvim/python-debug-install.sh"
fi

# Create symlinks for other configuration files
echo -e "${YELLOW}Creating symlinks for other config files...${NC}"
ln -sf "$DOT_DEN/.bashrc" ~/.bashrc
ln -sf "$DOT_DEN/.bash_aliases" ~/.bash_aliases
ln -sf "$DOT_DEN/.bash_exports" ~/.bash_exports
ln -sf "$DOT_DEN/.gitconfig" ~/.gitconfig
ln -sf "$DOT_DEN/.tmux.conf" ~/.tmux.conf

# Create secrets file from template
if [[ -f "$DOT_DEN/.bash_secrets.example" && ! -f ~/.bash_secrets ]]; then
    echo -e "${YELLOW}Creating secrets file from template...${NC}"
    cp "$DOT_DEN/.bash_secrets.example" ~/.bash_secrets
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
    if [[ -f "$DOT_DEN/arch-linux/setup.sh" ]]; then
        echo -e "${YELLOW}Running Arch Linux specific setup...${NC}"
        bash "$DOT_DEN/arch-linux/setup.sh"
    else
        echo -e "${YELLOW}No Arch Linux setup script found. Skipping Arch-specific setup.${NC}"
    fi
fi

# Check if this is a Raspberry Pi and run Pi-specific setup if needed
if grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo -e "${YELLOW}Detected Raspberry Pi hardware!${NC}"
    
    # Check if Raspberry Pi setup script exists
    if [[ -f "$DOT_DEN/raspberry-pi/setup.sh" ]]; then
        echo -e "${YELLOW}Running Raspberry Pi specific setup...${NC}"
        bash "$DOT_DEN/raspberry-pi/setup.sh"
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


# Check and install npm for Claude Code if needed
if ! command -v npm >/dev/null 2>&1; then
  echo -e "${YELLOW}📦 npm not found. Installing nodejs and npm...${NC}"
  if command -v apt >/dev/null 2>&1; then
    # Debian/Ubuntu
    sudo apt update && sudo apt install -y nodejs npm
  elif command -v pacman >/dev/null 2>&1; then
    # Arch Linux
    sudo pacman -S --needed nodejs npm
  elif command -v brew >/dev/null 2>&1; then
    # macOS
    brew install node
  else
    echo -e "${RED}Unable to install npm automatically. Please install nodejs and npm manually.${NC}"
    echo -e "${BLUE}See https://nodejs.org/en/download/ for installation instructions.${NC}"
  fi
fi

# Install uv for Python package management
if ! command -v uv >/dev/null 2>&1; then
  echo -e "${YELLOW}📦 Installing uv...${NC}"
  curl -Ls https://astral.sh/uv/install.sh | sh
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
fi
