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
    # Removed cd command to prevent changing user's directory when sourced
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
ln -sf "$DOT_DEN/.bash_profile" ~/.bash_profile
# Create directory for modular aliases if it doesn't exist
mkdir -p ~/.bash_aliases.d
# Copy the contents instead of creating a symlink to avoid recursive symlink issues
cp -r "$DOT_DEN/.bash_aliases.d/"* ~/.bash_aliases.d/ 2>/dev/null || true
ln -sf "$DOT_DEN/.bash_exports" ~/.bash_exports
ln -sf "$DOT_DEN/.tmux.conf" ~/.tmux.conf
# Global Configuration: ~/.aws/amazonq/mcp.json - Applies to all workspaces
# (as opposed to Workspace Configuration: .amazonq/mcp.json - Specific to the current workspace)
mkdir -p ~/.aws/amazonq
if [[ ! -f ~/.aws/amazonq/mcp.json ]] || ! cmp -s "$DOT_DEN"/mcp/mcp.json ~/.aws/amazonq/mcp.json; then
    cp "$DOT_DEN"/mcp/mcp.json ~/.aws/amazonq/mcp.json
fi

# Claude Desktop MCP integration
mkdir -p ~/.config/Claude
if [[ ! -f ~/.config/Claude/claude_desktop_config.json ]] || ! cmp -s "$DOT_DEN"/mcp/mcp.json ~/.config/Claude/claude_desktop_config.json; then
    cp "$DOT_DEN"/mcp/mcp.json ~/.config/Claude/claude_desktop_config.json
fi

# Apply environment-specific MCP server configuration
if [[ -f "$DOT_DEN/utils/mcp-environment.sh" ]]; then
  # Source the MCP environment utility
  # shellcheck disable=SC1090
  source "$DOT_DEN/utils/mcp-environment.sh"
  
  # Detect current environment
  CURRENT_ENV=$(detect_environment)
  echo "Configuring MCP servers for $CURRENT_ENV environment..."
  
  # Apply environment-specific configuration to all MCP config files
  filter_mcp_config ~/.aws/amazonq/mcp.json "$CURRENT_ENV"
  filter_mcp_config ~/.config/Claude/claude_desktop_config.json "$CURRENT_ENV"
fi

# Set up Git configuration
echo "Setting up Git configuration..."
gitconfig_path="$HOME/.gitconfig"
dotfiles_gitconfig="$DOT_DEN/.gitconfig"

# Remove existing gitconfig and copy fresh
rm -f "$gitconfig_path"
cp "$dotfiles_gitconfig" "$gitconfig_path"
echo -e "${GREEN}✓ Git configuration created${NC}"

# Set up modular Git configurations
echo "Setting up modular Git configurations..."

# Work Git configuration
work_gitconfig_source="$DOT_DEN/.gitconfig.work"
work_gitconfig_target="$HOME/.gitconfig-work"
if [[ -f "$work_gitconfig_source" ]]; then
    ln -sf "$work_gitconfig_source" "$work_gitconfig_target"
    echo -e "${GREEN}✓ Work Git configuration linked${NC}"
fi

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

# Amazon Q CLI setup and management
echo -e "${DIVIDER}"
echo "Setting up Amazon Q CLI..."

# Setup Amazon Q CLI (install, update, configure)
if [[ -f "$DOT_DEN/utils/install-amazon-q.sh" ]]; then
  source "$DOT_DEN/utils/install-amazon-q.sh"
  setup_amazon_q || {
    echo -e "${RED}Failed to setup Amazon Q CLI completely. Some features may not work.${NC}"
    echo "You can install it manually later from: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-getting-started-installing.html"
  }
else
  echo -e "${RED}Amazon Q installation script not found at $DOT_DEN/utils/install-amazon-q.sh${NC}"
fi

# Node.js setup with NVM
echo -e "${DIVIDER}"
echo "Setting up Node.js with NVM..."

# Fix npm prefix configuration conflict with nvm
if [ -f "$DOT_DEN/utils/fix-npm-nvm-conflict.sh" ]; then
  bash "$DOT_DEN/utils/fix-npm-nvm-conflict.sh"
fi

# Ensure NVM directory exists
export NVM_DIR="$HOME/.nvm"

# Install NVM if not already installed
if [ ! -d "$NVM_DIR" ]; then
  echo "Installing NVM (Node Version Manager)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1
  
  # Source NVM immediately after installation
  if [ -d "$NVM_DIR" ]; then
    if [ -s "$NVM_DIR/nvm.sh" ]; then
      # shellcheck source=/dev/null
      . "$NVM_DIR/nvm.sh"
    fi
    if [ -s "$NVM_DIR/bash_completion" ]; then
      # shellcheck source=/dev/null
      . "$NVM_DIR/bash_completion"
    fi
  fi
  
  # Install latest LTS version of Node.js and set as default
  nvm install --lts >/dev/null 2>&1
  nvm use --lts >/dev/null 2>&1
  nvm alias default 'lts/*' >/dev/null 2>&1
  
  NODE_VERSION=$(node -v 2>/dev/null || echo "unknown")
  echo -e "${GREEN}✓ Node.js LTS version ${NODE_VERSION} installed and set as default${NC}"
else
  # Source NVM if it exists
  if [ -d "$NVM_DIR" ]; then
    if [ -s "$NVM_DIR/nvm.sh" ]; then
      # shellcheck source=/dev/null
      . "$NVM_DIR/nvm.sh"
    fi
    if [ -s "$NVM_DIR/bash_completion" ]; then
      # shellcheck source=/dev/null
      . "$NVM_DIR/bash_completion"
    fi
  fi
  
  # Check if NVM is available
  if command -v nvm >/dev/null 2>&1; then
    CURRENT_NODE_VERSION=$(node -v 2>/dev/null || echo "none")
    LATEST_LTS=$(nvm version-remote --lts 2>/dev/null || echo "unknown")
    
    # Remove 'v' prefix for version comparison
    CURRENT_VERSION=${CURRENT_NODE_VERSION#v}
    LATEST_VERSION=${LATEST_LTS#v}
    
    # Check if current version is different from latest LTS
    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "unknown" ]; then
      echo "Updating Node.js from $CURRENT_NODE_VERSION to $LATEST_LTS..."
      nvm install --lts >/dev/null 2>&1
      nvm use --lts >/dev/null 2>&1
      nvm alias default 'lts/*' >/dev/null 2>&1
      NEW_VERSION=$(node -v)
      echo -e "${GREEN}✓ Node.js updated to latest LTS version: ${NEW_VERSION}${NC}"
    else
      echo -e "${GREEN}✓ Node.js is already at the latest LTS version: ${CURRENT_NODE_VERSION}${NC}"
    fi
  else
    echo -e "${YELLOW}NVM installation found but not working properly. Reinstalling...${NC}"
    rm -rf "$NVM_DIR"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1
    if [ -d "$NVM_DIR" ]; then
      if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
      fi
      if [ -s "$NVM_DIR/bash_completion" ]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/bash_completion"
      fi
    fi
    nvm install --lts >/dev/null 2>&1
    nvm use --lts >/dev/null 2>&1
    nvm alias default 'lts/*' >/dev/null 2>&1
    NODE_VERSION=$(node -v 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Node.js LTS version ${NODE_VERSION} installed and set as default${NC}"
  fi
fi

# Install uv for Python package management
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv package manager..."
  curl -Ls https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
  # Check if PATH already contains the .local/bin entry before adding
  if ! grep -q "export PATH=\"\\$HOME/.local/bin:\\$PATH\"" "$HOME/.bashrc"; then
    echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
  fi
  # Make uv available in the current shell
  export PATH="$HOME/.local/bin:$PATH"
  echo -e "${GREEN}✓ uv package manager installed${NC}"
fi

# GitHub CLI setup and update
echo -e "${DIVIDER}"
echo "Checking GitHub CLI..."

# Ensure Homebrew is available on macOS before proceeding
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Source the Homebrew utility script
  if [[ -f "$DOT_DEN/utils/ensure-homebrew.sh" ]]; then
    source "$DOT_DEN/utils/ensure-homebrew.sh"
    ensure_homebrew_on_macos || {
      echo -e "${RED}Failed to ensure Homebrew is installed. GitHub CLI installation may fail.${NC}"
    }
  else
    echo -e "${RED}Homebrew utility script not found at $DOT_DEN/utils/ensure-homebrew.sh${NC}"
  fi
fi

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
        VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
        
        # Download and extract
        curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${VERSION}_linux_amd64.tar.gz"
        tar xzf gh.tar.gz
        sudo install -o root -g root -m 0755 gh_"${VERSION}"_linux_amd64/bin/gh /usr/local/bin/gh
        sudo cp -r gh_"${VERSION}"_linux_amd64/share/man/man1/* /usr/local/share/man/man1/ 2>/dev/null || true
        rm -rf gh_"${VERSION}"_linux_amd64 gh.tar.gz
      ) || echo -e "${YELLOW}Failed to install/update GitHub CLI via binary. Continuing...${NC}"
    fi
  
  # For macOS
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      echo "Using Homebrew installation..."
      (brew install gh || brew upgrade gh) || echo -e "${YELLOW}Failed to install/update GitHub CLI via Homebrew. Continuing...${NC}"
    else
      echo -e "${RED}Homebrew installation failed earlier. Cannot install GitHub CLI.${NC}"
      echo "Please install Homebrew manually: https://brew.sh"
      return 1
    fi
  else
    echo -e "${YELLOW}Unsupported OS: $OSTYPE. Please install GitHub CLI manually.${NC}"
  fi
}

# Check if GitHub CLI is installed
if command -v gh &> /dev/null; then
  CURRENT_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
  echo "Current GitHub CLI version: $CURRENT_VERSION"
  
  # Get the latest available version from GitHub
  LATEST_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
  
  # Check if update is needed
  if [[ -n "$LATEST_VERSION" && "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Newer version available: $LATEST_VERSION. Updating GitHub CLI..."
    install_or_update_gh_cli
    
    # Verify update
    if command -v gh &> /dev/null; then
      NEW_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
      if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
        echo -e "${GREEN}✓ GitHub CLI updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
      else
        echo -e "${YELLOW}GitHub CLI update attempted but version remained at $CURRENT_VERSION${NC}"
      fi
    fi
  else
    echo -e "${GREEN}✓ GitHub CLI is already at the latest version ($CURRENT_VERSION)${NC}"
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

# Git Delta setup
echo -e "${DIVIDER}"
echo "Checking Git Delta setup..."

# Check if Git Delta is referenced in gitconfig
if grep -q "delta" ~/.gitconfig 2>/dev/null; then
  echo "Git Delta is referenced in your gitconfig."
  
  # Check if Git Delta is installed
  if command -v delta &> /dev/null; then
    echo -e "${GREEN}✓ Git Delta is already installed${NC}"
  else
    echo "Git Delta is not installed. Installing now..."
    if [ -f "$DOT_DEN/utils/install-git-delta.sh" ]; then
      bash "$DOT_DEN/utils/install-git-delta.sh"
    else
      echo -e "${RED}Git Delta installation script not found.${NC}"
      echo "Please install Git Delta manually or your git diff commands may fail."
    fi
  fi
else
  echo "Git Delta is not referenced in your gitconfig. Skipping installation."
fi

# Docker setup
echo -e "${DIVIDER}"
echo "Checking Docker setup..."

# Check if Docker is already installed
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✓ Docker is already installed${NC}"
else
  # Source and run Docker installation script
  if [[ -f "$DOT_DEN/utils/install-docker.sh" ]]; then
    source "$DOT_DEN/utils/install-docker.sh"
    install_docker || {
      echo -e "${RED}Docker installation failed.${NC}"
      echo "Please try installing Docker manually for your system."
    }
  else
    echo -e "${RED}Docker installation script not found at $DOT_DEN/utils/install-docker.sh${NC}"
    echo "Please check your dotfiles installation."
  fi
fi

# Check if user is in docker group (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if groups | grep -q docker; then
    echo -e "${GREEN}✓ User is in the docker group${NC}"
  else
    echo -e "${YELLOW}User is not in the docker group.${NC}"
    echo "To add yourself to the docker group, run:"
    echo -e "${GREEN}sudo usermod -aG docker \$USER${NC}"
    echo "Then log out and back in for changes to take effect."
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo -e "${BLUE}Docker Desktop on macOS doesn't require group membership${NC}"
fi

# Test Docker if it's installed (without sudo)
if command -v docker &> /dev/null; then
  echo "Testing Docker access..."
  if docker info &>/dev/null; then
    echo -e "${GREEN}✓ Docker is working correctly${NC}"
    # Only run hello-world if Docker is working - with robust error handling
    echo "Running Docker hello-world test..."
    if docker run --rm hello-world &>/dev/null; then
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

# Source bash aliases to make them immediately available
echo "Loading bash aliases into current session..."
if [[ -f ~/.bash_aliases ]]; then
  # shellcheck disable=SC1090
  source ~/.bash_aliases
  echo -e "${GREEN}✓ Bash aliases loaded successfully${NC}"
fi

# Source bash exports to make environment variables available
echo "Loading environment variables from bash_exports..."
if [[ -f ~/.bash_exports ]]; then
  # shellcheck disable=SC1090
  source ~/.bash_exports
  echo -e "${GREEN}✓ Environment variables loaded successfully${NC}"
fi

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
echo "Your development environment is now configured and ready to use."
echo -e "${DIVIDER}"

# Final debug message
echo "Debug: Setup script completed successfully"