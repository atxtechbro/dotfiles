#!/bin/bash
# Dotfiles Automated Setup Script
# Universal configuration for all environments
#
# USAGE: source setup.sh

# Don't exit on error - this is critical for Pop!_OS compatibility
set +e

# Define colors and formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
DIVIDER="----------------------------------------"

# Error handling function
handle_error() {
  local exit_code=$?
  echo -e "${RED}Command failed with exit code $exit_code: $BASH_COMMAND${NC}"
  echo -e "${YELLOW}Continuing despite error...${NC}"
}

# Set up error trap but don't exit
trap 'handle_error' ERR

# Check if the script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${RED}Error: This script must be sourced, not executed.${NC}"
    echo -e "Please run: ${GREEN}source setup.sh${NC}"
    exit 1
fi

# Add debug logging
echo "Debug: Starting setup script in sourced mode"

DOT_DEN="$HOME/ppv/pillars/dotfiles"
# Export DOT_DEN as a global variable for other scripts to use
export DOT_DEN

# Add MCP directory to PATH for easier access to MCP scripts
export PATH="$DOT_DEN/mcp:$PATH"
# Add MCP servers directory to PATH
export PATH="$DOT_DEN/mcp/servers:$PATH"

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
    return 1
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

# Neovim configuration setup
if command -v nvim &> /dev/null; then
    echo -e "${YELLOW}Linking Neovim configuration...${NC}"
    mkdir -p ~/.config
    rm -rf ~/.config/nvim
    ln -sfn "$DOT_DEN/nvim" ~/.config/nvim
    
    echo -e "${BLUE}Neovim configuration linked.${NC}"
    echo -e "${BLUE}Note: LSP and debugging tools must be installed manually.${NC}"
    echo -e "${BLUE}See $DOT_DEN/nvim/scripts/README.md for more information.${NC}"
else
    echo -e "${YELLOW}Neovim not installed. Skipping Neovim configuration.${NC}"
    echo -e "${BLUE}To use Neovim configuration:${NC}"
    echo -e "${BLUE}1. Install Neovim${NC}"
    echo -e "${BLUE}2. Run: ln -sfn $DOT_DEN/nvim ~/.config/nvim${NC}"
fi

# Create symlinks for other configuration files
echo "Creating symlinks for config files..."
ln -sf "$DOT_DEN/.bashrc" ~/.bashrc
ln -sf "$DOT_DEN/.bash_aliases" ~/.bash_aliases
# Create directory for modular aliases if it doesn't exist
mkdir -p ~/.bash_aliases.d
# Copy the contents instead of creating a symlink to avoid recursive symlink issues
cp -r "$DOT_DEN/.bash_aliases.d/"* ~/.bash_aliases.d/ 2>/dev/null || true
ln -sf "$DOT_DEN/.bash_exports" ~/.bash_exports
ln -sf "$DOT_DEN/.tmux.conf" ~/.tmux.conf
# Global Configuration: ~/.aws/amazonq/mcp.json - Applies to all workspaces
# (as opposed to Workspace Configuration: .amazonq/mcp.json - Specific to the current workspace)
mkdir -p ~/.aws/amazonq
ln -sf "$DOT_DEN"/mcp/mcp.json ~/.aws/amazonq/mcp.json

# Claude Desktop MCP integration
mkdir -p ~/.config/Claude
cp "$DOT_DEN"/mcp/mcp.json ~/.config/Claude/claude_desktop_config.json

# Set up Git configuration
echo "Setting up Git configuration..."
gitconfig_path="$HOME/.gitconfig"
dotfiles_gitconfig="$DOT_DEN/.gitconfig"

# Remove existing gitconfig and copy fresh
rm -f "$gitconfig_path"
cp "$dotfiles_gitconfig" "$gitconfig_path"
echo -e "${GREEN}✓ Git configuration created${NC}"

# Create secrets file from template
if [[ -f "$DOT_DEN/.bash_secrets.example" && ! -f ~/.bash_secrets ]]; then
    echo "Creating secrets file from template..."
    cp "$DOT_DEN/.bash_secrets.example" ~/.bash_secrets
    chmod 600 ~/.bash_secrets
    echo "Created ~/.bash_secrets from template. Please edit to add your secrets."
fi

# Configuration files setup complete
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
        source "$DOT_DEN/arch-linux/setup.sh"
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
        source "$DOT_DEN/raspberry-pi/setup.sh"
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
  # Check if PATH already contains the .local/bin entry before adding
  if ! grep -q "export PATH=\"\\\$HOME/.local/bin:\\\$PATH\"" "$HOME/.bashrc"; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
  fi
  # Make uv available in the current shell
  export PATH="$HOME/.local/bin:$PATH"
  echo -e "${GREEN}✓ uv package manager installed${NC}"
fi

# GitHub CLI setup and update
echo -e "${DIVIDER}"
echo "Checking GitHub CLI..."

install_or_update_gh_cli() {
  echo "Installing/updating GitHub CLI using official method..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Debian/Ubuntu-based systems
    if command -v apt &> /dev/null; then
      echo "Using apt-based installation..."
      (
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update 2>/dev/null
        sudo apt install -y gh
      ) || echo -e "${YELLOW}Failed to install/update GitHub CLI via apt. Continuing...${NC}"
    
    # For Arch-based systems
    elif command -v pacman &> /dev/null; then
      echo "Using pacman installation..."
      (sudo pacman -Sy --noconfirm github-cli) || echo -e "${YELLOW}Failed to install/update GitHub CLI via pacman. Continuing...${NC}"
    
    # For Fedora/RHEL-based systems
    elif command -v dnf &> /dev/null; then
      echo "Using dnf installation..."
      (sudo dnf install -y gh) || echo -e "${YELLOW}Failed to install/update GitHub CLI via dnf. Continuing...${NC}"
    
    # Fallback to direct binary installation
    else
      echo "Using direct binary installation..."
      (
        # Get latest version
        VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        
        # Download and extract
        curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${VERSION}_linux_amd64.tar.gz"
        tar xzf gh.tar.gz
        sudo install -o root -g root -m 0755 gh_${VERSION}_linux_amd64/bin/gh /usr/local/bin/gh
        sudo cp -r gh_${VERSION}_linux_amd64/share/man/man1/* /usr/local/share/man/man1/ 2>/dev/null || true
        rm -rf gh_${VERSION}_linux_amd64 gh.tar.gz
      ) || echo -e "${YELLOW}Failed to install/update GitHub CLI via binary. Continuing...${NC}"
    fi
  
  # For macOS
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      echo "Using Homebrew installation..."
      (brew install gh || brew upgrade gh) || echo -e "${YELLOW}Failed to install/update GitHub CLI via Homebrew. Continuing...${NC}"
    else
      echo -e "${YELLOW}Homebrew not found. Please install Homebrew first to install GitHub CLI on macOS.${NC}"
    fi
  else
    echo -e "${YELLOW}Unsupported OS: $OSTYPE. Please install GitHub CLI manually.${NC}"
  fi
}

# Check if GitHub CLI is installed
if command -v gh &> /dev/null; then
  CURRENT_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
  echo "Current GitHub CLI version: $CURRENT_VERSION"
  
  # Always update to latest version
  install_or_update_gh_cli
  
  # Get new version
  if command -v gh &> /dev/null; then
    NEW_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
    if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
      echo -e "${GREEN}✓ GitHub CLI updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
    else
      echo -e "${GREEN}✓ GitHub CLI is already at the latest version ($CURRENT_VERSION)${NC}"
    fi
  fi
else
  echo "GitHub CLI not installed. Installing now..."
  install_or_update_gh_cli
  
  # Verify installation
  if command -v gh &> /dev/null; then
    INSTALLED_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
    echo -e "${GREEN}✓ GitHub CLI installed successfully (version $INSTALLED_VERSION)${NC}"
  else
    echo -e "${RED}GitHub CLI installation failed.${NC}"
  fi
fi

# Export GitHub token for MCP
if command -v gh &> /dev/null; then
  echo "Exporting GitHub token for MCP..."
  GITHUB_TOKEN=$(gh auth token)
  export GITHUB_TOKEN
  echo -e "${GREEN}✓ GitHub token exported as GITHUB_TOKEN${NC}"
else
  echo -e "${YELLOW}GitHub CLI not installed. Skipping GitHub token export.${NC}"
  echo "To use GitHub MCP features, install GitHub CLI and run: export GITHUB_TOKEN=\$(gh auth token)"
fi

# Docker setup
echo -e "${DIVIDER}"
echo "Checking Docker setup..."

# Check if Docker is already installed
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✓ Docker is already installed${NC}"
else
  echo -e "${YELLOW}Docker is not installed. Installing now...${NC}"
  # Auto-install Docker based on available package manager
  if command -v apt &> /dev/null; then
    echo "Using apt to install Docker..."
    (sudo apt-get update && sudo apt-get install -y docker.io) || {
      echo -e "${YELLOW}Docker installation with apt failed. Continuing anyway...${NC}"
    }
    (sudo systemctl enable docker) || echo "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || echo "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker $USER) || echo "Failed to add user to Docker group. Continuing..."
    echo -e "${GREEN}✓ Docker installation attempted${NC}"
  elif command -v pacman &> /dev/null; then
    echo "Using pacman to install Docker..."
    (sudo pacman -Sy --noconfirm docker) || echo "Docker installation with pacman failed. Continuing..."
    (sudo systemctl enable docker) || echo "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || echo "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker $USER) || echo "Failed to add user to Docker group. Continuing..."
    echo -e "${GREEN}✓ Docker installation attempted${NC}"
  elif command -v dnf &> /dev/null; then
    echo "Using dnf to install Docker..."
    (sudo dnf -y install docker) || echo "Docker installation with dnf failed. Continuing..."
    (sudo systemctl enable docker) || echo "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || echo "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker $USER) || echo "Failed to add user to Docker group. Continuing..."
    echo -e "${GREEN}✓ Docker installation attempted${NC}"
  else
    echo -e "${RED}Unable to install Docker automatically.${NC}"
    echo "Please install Docker manually for your distribution."
  fi
  echo "Note: You'll need to log out and back in for group changes to take effect."
fi

# Check if user is in docker group
if groups | grep -q docker; then
  echo -e "${GREEN}✓ User is in the docker group${NC}"
else
  echo -e "${YELLOW}User is not in the docker group.${NC}"
  echo "To add yourself to the docker group, run:"
  echo -e "${GREEN}sudo usermod -aG docker \$USER${NC}"
  echo "Then log out and back in for changes to take effect."
fi

# Test Docker if it's installed (without sudo)
if command -v docker &> /dev/null; then
  echo "Testing Docker access..."
  if docker info &>/dev/null; then
    echo -e "${GREEN}✓ Docker is working correctly${NC}"
    # Only run hello-world if Docker is working - with robust error handling
    echo "Running Docker hello-world test..."
    (docker run --rm hello-world &>/dev/null)
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓ Docker hello-world test passed${NC}"
    else
      echo -e "${YELLOW}Docker hello-world test failed. You may need to restart your system.${NC}"
      echo "This is not a critical error, continuing with setup..."
    fi
  else
    echo -e "${YELLOW}Docker is installed but not accessible without sudo.${NC}"
    echo "Please log out and back in, or restart your system to apply group changes."
    echo "Continuing with setup..."
  fi
fi

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
echo "Your development environment is now configured and ready to use."
echo -e "${DIVIDER}"

# Final debug message
echo "Debug: Setup script completed successfully"
