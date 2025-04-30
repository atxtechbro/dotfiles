#!/bin/bash
# Dotfiles Automated Setup Script
# Universal configuration for all environments

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
DIVIDER="${CYAN}----------------------------------------${NC}"

DOT_DEN="$HOME/ppv/pillars/dotfiles"

echo -e "${DIVIDER}"
echo -e "${GREEN}▶ Starting dotfiles setup...${NC}"
echo -e "${DIVIDER}"

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
    git clone https://github.com/atxtechbro/dotfiles.git "$DOT_DEN" 2>/dev/null
    echo -e "${GREEN}Dotfiles repository cloned successfully!${NC}"
elif [[ -d "$DOT_DEN" ]]; then
    echo -e "${BLUE}Dotfiles repository already exists at $DOT_DEN${NC}"
    cd "$DOT_DEN" 2>/dev/null
fi

echo -e "${DIVIDER}"
echo -e "${GREEN}▶ Setting up Neovim...${NC}"
echo -e "${DIVIDER}"

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${YELLOW}Neovim not found. Installing...${NC}"
    
    # Download latest Neovim release
    NVIM_TMP_DIR=$(mktemp -d)
    NVIM_RELEASE="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    
    echo -e "${BLUE}Downloading Neovim...${NC}"
    curl -L -o "${NVIM_TMP_DIR}/nvim.tar.gz" "${NVIM_RELEASE}" 2>/dev/null
    
    # Install Neovim
    echo -e "${BLUE}Installing Neovim to /opt...${NC}"
    sudo rm -rf /opt/nvim 2>/dev/null
    sudo tar -C /opt -xzf "${NVIM_TMP_DIR}/nvim.tar.gz" 2>/dev/null
    
    # Clean up
    rm -rf "${NVIM_TMP_DIR}" 2>/dev/null
    
    # Add to PATH if not already there
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.bashrc; then
        echo -e "${BLUE}Adding Neovim to PATH...${NC}"
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
        export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    fi
    
    echo -e "${GREEN}Neovim installed successfully!${NC}"
fi

# Link Neovim configuration
echo -e "${BLUE}Linking Neovim configuration...${NC}"
rm -rf ~/.config/nvim 2>/dev/null
ln -sfn "$DOT_DEN/nvim" ~/.config/nvim

# Install Neovim dependencies
echo -e "${BLUE}Installing Neovim dependencies...${NC}"

# Run LSP install script
if [ -f "$DOT_DEN/nvim/scripts/lsp-install.sh" ]; then
    echo -e "${YELLOW}Installing LSP servers...${NC}"
    bash "$DOT_DEN/nvim/scripts/lsp-install.sh"
elif [ -f "$DOT_DEN/nvim/lsp-install.sh" ]; then
    echo -e "${YELLOW}Installing LSP servers...${NC}"
    bash "$DOT_DEN/nvim/lsp-install.sh"
fi

# Run Python debug install script
if [ -f "$DOT_DEN/nvim/scripts/python-debug-install.sh" ]; then
    echo -e "${YELLOW}Installing Python debugging tools...${NC}"
    bash "$DOT_DEN/nvim/scripts/python-debug-install.sh"
elif [ -f "$DOT_DEN/nvim/python-debug-install.sh" ]; then
    echo -e "${YELLOW}Installing Python debugging tools...${NC}"
    bash "$DOT_DEN/nvim/python-debug-install.sh"
fi

echo -e "${GREEN}✓ Neovim setup complete${NC}"

echo -e "${DIVIDER}"
echo -e "${GREEN}▶ Setting up configuration files...${NC}"
echo -e "${DIVIDER}"

# Create symlinks for other configuration files
echo -e "${BLUE}Creating symlinks for config files...${NC}"
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
    echo -e "${BLUE}Created ~/.bash_secrets from template. Please edit to add your secrets.${NC}"
fi

# Apply bash configuration
echo -e "${BLUE}Applying bash configuration...${NC}"
# shellcheck disable=SC1090
source ~/.bashrc 2>/dev/null || true

echo -e "${GREEN}✓ Configuration files setup complete${NC}"

# Platform-specific setup
echo -e "${DIVIDER}"
echo -e "${GREEN}▶ Platform-specific setup...${NC}"
echo -e "${DIVIDER}"

# Check if this is running on Arch Linux and offer Arch-specific setup
if command -v pacman &>/dev/null; then
    echo -e "${YELLOW}Detected Arch Linux!${NC}"
    
    # Check if Arch Linux setup script exists
    if [[ -f "$DOT_DEN/arch-linux/setup.sh" ]]; then
        echo -e "${YELLOW}Running Arch Linux specific setup...${NC}"
        bash "$DOT_DEN/arch-linux/setup.sh"
    else
        echo -e "${BLUE}No Arch Linux setup script found. Skipping Arch-specific setup.${NC}"
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
        echo -e "${BLUE}No Raspberry Pi setup script found. Skipping Pi-specific setup.${NC}"
    fi
fi

# Tools setup
echo -e "${DIVIDER}"
echo -e "${GREEN}▶ Setting up development tools...${NC}"
echo -e "${DIVIDER}"

# Amazon Q setup and management
if command -v q >/dev/null 2>&1; then
  echo -e "${YELLOW}Amazon Q: Checking for updates...${NC}"
  
  # Check if update is available
  UPDATE_CHECK=$(q update 2>&1 | grep "A new version of q is available:" || echo "")
  
  if [ -n "$UPDATE_CHECK" ]; then
    echo -e "${YELLOW}Amazon Q update available. Installing...${NC}"
    
    # Determine architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
      curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip" -o "q.zip" 2>/dev/null
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
      curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-aarch64-linux.zip" -o "q.zip" 2>/dev/null
    else
      echo -e "${RED}Unsupported architecture: $ARCH. Cannot update Amazon Q automatically${NC}"
    fi
    
    # Install if zip was downloaded
    if [ -f "q.zip" ]; then
      unzip -o q.zip >/dev/null 2>&1
      ./q/install.sh >/dev/null 2>&1
      rm -rf q.zip q/ >/dev/null 2>&1
      echo -e "${GREEN}✓ Amazon Q updated successfully${NC}"
    fi
  else
    echo -e "${GREEN}✓ Amazon Q is up to date${NC}"
  fi
  
  # Disable telemetry if not already disabled
  TELEMETRY_STATUS=$(q telemetry status 2>/dev/null | grep -i "disabled" || echo "")
  if [ -z "$TELEMETRY_STATUS" ]; then
    echo -e "${YELLOW}Disabling Amazon Q telemetry...${NC}"
    q telemetry disable >/dev/null 2>&1
    echo -e "${GREEN}✓ Amazon Q telemetry disabled${NC}"
  else
    echo -e "${BLUE}Amazon Q telemetry already disabled${NC}"
  fi
fi

# Check and install npm for Claude Code if needed
if ! command -v npm >/dev/null 2>&1; then
  echo -e "${YELLOW}NodeJS: npm not found. Installing nodejs and npm...${NC}"
  if command -v apt >/dev/null 2>&1; then
    # Debian/Ubuntu
    sudo apt update >/dev/null 2>&1
    sudo apt install -y nodejs npm >/dev/null 2>&1
    echo -e "${GREEN}✓ NodeJS and npm installed${NC}"
  elif command -v pacman >/dev/null 2>&1; then
    # Arch Linux
    sudo pacman -S --needed nodejs npm >/dev/null 2>&1
    echo -e "${GREEN}✓ NodeJS and npm installed${NC}"
  elif command -v brew >/dev/null 2>&1; then
    # macOS
    brew install node >/dev/null 2>&1
    echo -e "${GREEN}✓ NodeJS and npm installed${NC}"
  else
    echo -e "${RED}Unable to install npm automatically. Please install manually:${NC}"
    echo -e "${BLUE}See https://nodejs.org/en/download/ for installation instructions.${NC}"
  fi
fi

# Install uv for Python package management
if ! command -v uv >/dev/null 2>&1; then
  echo -e "${YELLOW}Python: Installing uv package manager...${NC}"
  curl -Ls https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
  echo -e "${GREEN}✓ uv package manager installed${NC}"
fi

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
echo -e "${BLUE}Your development environment is now configured and ready to use.${NC}"
echo -e "${DIVIDER}"
