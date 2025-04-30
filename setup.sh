#!/bin/bash
# Dotfiles Automated Setup Script
# Universal configuration for all environments

set -e  # Exit on error

# Colors for output - use sparingly
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
DIVIDER="----------------------------------------"

DOT_DEN="$HOME/ppv/pillars/dotfiles"

# Export flag to tell subscripts we're running from the main setup
export SETUP_SCRIPT_RUNNING=true

echo -e "${DIVIDER}"
echo -e "${GREEN}Setting up dotfiles...${NC}"
echo -e "${DIVIDER}"

# Check for essential tools
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Required command '$1' not found.${NC}"
        echo "Please install it using your package manager before running this script."
        echo "See the README.md for OS-specific installation instructions."
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
        echo "Detected Windows Subsystem for Linux (WSL)"
        IS_WSL=true
    else
        IS_WSL=false
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
    IS_WSL=false
else
    echo "Unrecognized OS: $OSTYPE. Proceeding anyway..."
    OS_TYPE="Unknown"
    IS_WSL=false
fi

echo "Detected OS: $OS_TYPE"

# Handle WSL-specific setup
if [[ "$IS_WSL" == true ]]; then
    echo "Setting up WSL-specific configuration..."
    if [[ -d "/mnt/c/dotfiles" ]]; then
        echo "Found dotfiles in Windows filesystem, creating symlink..."
        ln -sf /mnt/c/dotfiles "$DOT_DEN"
    fi
fi

# Clone dotfiles repository if it doesn't exist and we're not in WSL
if [[ ! -d "$DOT_DEN" && "$IS_WSL" == false ]]; then
    echo "Cloning dotfiles repository..."
    mkdir -p "$(dirname "$DOT_DEN")"
    git clone https://github.com/atxtechbro/dotfiles.git "$DOT_DEN" 2>/dev/null
    echo -e "${GREEN}✓ Repository cloned successfully${NC}"
elif [[ -d "$DOT_DEN" ]]; then
    echo "Dotfiles repository already exists at $DOT_DEN"
    cd "$DOT_DEN" 2>/dev/null
fi

echo -e "${DIVIDER}"
echo "Setting up Neovim..."

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo "Neovim not found. Installing..."
    
    # Download latest Neovim release
    NVIM_TMP_DIR=$(mktemp -d)
    NVIM_RELEASE="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    
    echo "Downloading and installing Neovim..."
    curl -L -o "${NVIM_TMP_DIR}/nvim.tar.gz" "${NVIM_RELEASE}" 2>/dev/null
    sudo rm -rf /opt/nvim 2>/dev/null
    sudo tar -C /opt -xzf "${NVIM_TMP_DIR}/nvim.tar.gz" 2>/dev/null
    rm -rf "${NVIM_TMP_DIR}" 2>/dev/null
    
    # Add to PATH if not already there
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.bashrc; then
        echo "Adding Neovim to PATH..."
        echo "export PATH=\"\$PATH:/opt/nvim-linux-x86_64/bin\"" >> ~/.bashrc
        export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    fi
    
    echo -e "${GREEN}✓ Neovim installed${NC}"
fi

# Link Neovim configuration
echo "Setting up Neovim configuration..."
rm -rf ~/.config/nvim 2>/dev/null
ln -sfn "$DOT_DEN/nvim" ~/.config/nvim

# Run LSP install script
if [ -f "$DOT_DEN/nvim/scripts/lsp-install.sh" ]; then
    echo "Installing LSP servers..."
    bash "$DOT_DEN/nvim/scripts/lsp-install.sh" 2>/dev/null
elif [ -f "$DOT_DEN/nvim/lsp-install.sh" ]; then
    echo "Installing LSP servers..."
    bash "$DOT_DEN/nvim/lsp-install.sh" 2>/dev/null
fi

# Run Python debug install script
if [ -f "$DOT_DEN/nvim/scripts/python-debug-install.sh" ]; then
    echo "Installing Python debugging tools..."
    bash "$DOT_DEN/nvim/scripts/python-debug-install.sh" 2>/dev/null
elif [ -f "$DOT_DEN/nvim/python-debug-install.sh" ]; then
    echo "Installing Python debugging tools..."
    bash "$DOT_DEN/nvim/python-debug-install.sh" 2>/dev/null
fi

echo -e "${GREEN}✓ Neovim setup complete${NC}"

echo -e "${DIVIDER}"
echo "Setting up configuration files..."

# Create symlinks for other configuration files
echo "Creating symlinks for config files..."
ln -sf "$DOT_DEN/.bashrc" ~/.bashrc
ln -sf "$DOT_DEN/.bash_aliases" ~/.bash_aliases
ln -sf "$DOT_DEN/.bash_exports" ~/.bash_exports
ln -sf "$DOT_DEN/.gitconfig" ~/.gitconfig
ln -sf "$DOT_DEN/.tmux.conf" ~/.tmux.conf

# Create secrets file from template
if [[ -f "$DOT_DEN/.bash_secrets.example" && ! -f ~/.bash_secrets ]]; then
    echo "Creating secrets file from template..."
    cp "$DOT_DEN/.bash_secrets.example" ~/.bash_secrets
    chmod 600 ~/.bash_secrets
    echo "Created ~/.bash_secrets from template. Please edit to add your secrets."
fi

# Apply bash configuration
echo "Applying bash configuration..."
# shellcheck disable=SC1090
source ~/.bashrc 2>/dev/null || true

echo -e "${GREEN}✓ Configuration files setup complete${NC}"

# Platform-specific setup
echo -e "${DIVIDER}"
echo "Checking for platform-specific setup..."

# Check if this is running on Arch Linux and offer Arch-specific setup
if command -v pacman &>/dev/null; then
    echo "Detected Arch Linux"
    
    # Check if Arch Linux setup script exists
    if [[ -f "$DOT_DEN/arch-linux/setup.sh" ]]; then
        echo "Running Arch Linux specific setup..."
        bash "$DOT_DEN/arch-linux/setup.sh"
    else
        echo "No Arch Linux setup script found. Skipping Arch-specific setup."
    fi
fi

# Check if this is a Raspberry Pi and run Pi-specific setup if needed
if grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo "Detected Raspberry Pi hardware"
    
    # Check if Raspberry Pi setup script exists
    if [[ -f "$DOT_DEN/raspberry-pi/setup.sh" ]]; then
        echo "Running Raspberry Pi specific setup..."
        bash "$DOT_DEN/raspberry-pi/setup.sh"
    else
        echo "No Raspberry Pi setup script found. Skipping Pi-specific setup."
    fi
fi

# Tools setup
echo -e "${DIVIDER}"
echo "Setting up development tools..."

# Amazon Q setup and management
if command -v q >/dev/null 2>&1; then
  echo "Checking Amazon Q..."
  
  # Check if update is available
  UPDATE_CHECK=$(q update 2>&1 | grep "A new version of q is available:" || echo "")
  
  if [ -n "$UPDATE_CHECK" ]; then
    echo "Amazon Q update available. Installing..."
    
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
      echo -e "${GREEN}✓ Amazon Q updated${NC}"
    fi
  else
    echo -e "${GREEN}✓ Amazon Q is up to date${NC}"
  fi
  
  # Disable telemetry if not already disabled
  TELEMETRY_STATUS=$(q telemetry status 2>/dev/null | grep -i "disabled" || echo "")
  if [ -z "$TELEMETRY_STATUS" ]; then
    echo "Disabling Amazon Q telemetry..."
    q telemetry disable >/dev/null 2>&1
    echo -e "${GREEN}✓ Amazon Q telemetry disabled${NC}"
  else
    echo "Amazon Q telemetry already disabled"
  fi
fi

# Check and install npm for Claude Code if needed
if ! command -v npm >/dev/null 2>&1; then
  echo "Installing nodejs and npm..."
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
    echo "See https://nodejs.org/en/download/ for installation instructions."
  fi
fi

# Install uv for Python package management
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv package manager..."
  curl -Ls https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
  echo -e "${GREEN}✓ uv package manager installed${NC}"
fi

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
echo "Your development environment is now configured and ready to use."
echo -e "${DIVIDER}"
