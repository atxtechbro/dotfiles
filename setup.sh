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

# Determine dotfiles root relative to this script's location
# Works from main repo OR worktrees - everything is relative to where you source from
# This makes the system self-documenting: source from where you want to work
DOT_DEN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Export DOT_DEN as a global variable for other scripts to use
export DOT_DEN

# Critical: Warn if running from worktree to prevent broken symlinks
if [[ "$DOT_DEN" == *"/worktrees/"* ]]; then
    echo -e "${YELLOW}WARNING: Running setup.sh from a worktree directory!${NC}"
    echo -e "${YELLOW}This will create symlinks that break when the worktree is deleted.${NC}"
    echo -e "${YELLOW}Consider running from the main repository instead.${NC}"
    # Remove user interaction and continue with the script
    echo -e "${YELLOW}Proceeding with setup - broken symlinks will be handled automatically.${NC}"
fi

# Add MCP directory to PATH for easier access to MCP scripts
export PATH="$DOT_DEN/mcp:$PATH"
# Add MCP servers directory to PATH
export PATH="$DOT_DEN/mcp/servers:$PATH"

# Export flag to tell subscripts we're running from the main setup
export SETUP_SCRIPT_RUNNING=true

# Disable Claude Code Bedrock usage by default
export CLAUDE_CODE_USE_BEDROCK=0

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
if [[ -f "$DOT_DEN/utils/install-neovim.sh" ]]; then
    source "$DOT_DEN/utils/install-neovim.sh"
    setup_neovim || {
        echo -e "${YELLOW}Neovim setup encountered issues but continuing...${NC}"
    }
else
    echo -e "${YELLOW}Neovim installation script not found. Skipping Neovim setup.${NC}"
    echo -e "${BLUE}To use Neovim configuration manually:${NC}"
    echo -e "${BLUE}1. Install Neovim${NC}"
    echo -e "${BLUE}2. Run: ln -sfn $DOT_DEN/nvim ~/.config/nvim${NC}"
fi

# Create symlinks for other configuration files
echo "Creating symlinks for config files..."

# Critical: Detect and fix broken symlinks from deleted worktrees
echo "Checking for broken symlinks from deleted worktrees..."
for config_file in .bashrc .bash_aliases .bash_profile .bash_exports .tmux.conf .zprofile .zshrc .zsh_prompt; do
    home_link="$HOME/$config_file"
    if [[ -L "$home_link" && ! -e "$home_link" ]]; then
        echo "Removing broken symlink: $home_link"
        rm -f "$home_link"
    fi
done

ln -sf "$DOT_DEN/.bashrc" ~/.bashrc
ln -sf "$DOT_DEN/.bash_aliases" ~/.bash_aliases
ln -sf "$DOT_DEN/.bash_profile" ~/.bash_profile
# Create directory for modular aliases if it doesn't exist
mkdir -p ~/.bash_aliases.d
# Copy the contents instead of creating a symlink to avoid recursive symlink issues
cp -r "$DOT_DEN/.bash_aliases.d/"* ~/.bash_aliases.d/ 2>/dev/null || true
ln -sf "$DOT_DEN/.bash_exports" ~/.bash_exports
ln -sf "$DOT_DEN/.tmux.conf" ~/.tmux.conf

# macOS-specific shell configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Setting up macOS shell configuration..."
    ln -sf "$DOT_DEN/.zprofile" ~/.zprofile
    
    # Ensure Homebrew is installed
    source "$DOT_DEN/utils/ensure-homebrew.sh"
    ensure_homebrew_on_macos
    
    # Install coreutils for timeout command
    if ! command -v timeout &> /dev/null && ! command -v gtimeout &> /dev/null; then
        echo "Installing coreutils for timeout command..."
        brew install coreutils
        echo -e "${GREEN}✓ coreutils installed (timeout available as gtimeout)${NC}"
    fi
    
    # Configure iTerm2 as default terminal
    echo "Configuring iTerm2 as default terminal..."
    defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.unix-executable";LSHandlerRoleAll="com.googlecode.iterm2";}'
    echo -e "${GREEN}✓ iTerm2 configured as default terminal${NC}"
    ln -sf "$DOT_DEN/.zshrc" ~/.zshrc
    ln -sf "$DOT_DEN/.zsh_prompt" ~/.zsh_prompt
    echo -e "${GREEN}✓ zprofile, zshrc, and zsh_prompt linked for macOS shell setup${NC}"
    
    # Offer iTerm2 installation for better terminal experience
    echo -e "${DIVIDER}"
    echo "Terminal setup for macOS..."
    if [[ -f "$DOT_DEN/utils/install-iterm2.sh" ]]; then
        source "$DOT_DEN/utils/install-iterm2.sh"
        install_iterm2
        
        if [[ -f "$DOT_DEN/utils/configure-iterm2.sh" ]]; then
            source "$DOT_DEN/utils/configure-iterm2.sh"
            configure_iterm2
        fi
    fi
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

# Create machine-specific exports file from template
if [[ -f "$DOT_DEN/.bash_exports.local.example" && ! -f ~/.bash_exports.local ]]; then
    echo "Creating machine-specific exports file from template..."
    cp "$DOT_DEN/.bash_exports.local.example" ~/.bash_exports.local
    echo "Created ~/.bash_exports.local from template. Please edit to configure your environment."
fi

# Create secrets file from template
if [[ -f "$DOT_DEN/.bash_secrets.example" && ! -f ~/.bash_secrets ]]; then
    echo "Creating secrets file from template..."
    cp "$DOT_DEN/.bash_secrets.example" ~/.bash_secrets
    chmod 600 ~/.bash_secrets
    echo "Created ~/.bash_secrets from template. Please edit to add your secrets."
fi

# Source bash exports early to make environment variables available for MCP configuration
echo "Loading environment variables from bash_exports..."
if [[ -f ~/.bash_exports ]]; then
  # shellcheck disable=SC1090
  source ~/.bash_exports
  echo -e "${GREEN}✓ Environment variables loaded successfully${NC}"
fi

# Set up Amazon Q global rules (Claude Code now uses --add-dir flag via alias)
"$DOT_DEN/utils/setup-amazonq-rules.sh"

# Command templates live in .claude/command-templates/
# Generated to ~/.claude/commands/ by generate-commands.sh below
# No symlink needed - templates are processed, not used directly

# Set up vendor-agnostic MCP configuration
if [[ -f "$DOT_DEN/mcp/setup-vendor-agnostic-mcp.sh" ]]; then
  "$DOT_DEN/mcp/setup-vendor-agnostic-mcp.sh"
else
  echo -e "${YELLOW}Vendor-agnostic MCP setup script not found. Skipping MCP configuration setup.${NC}"
fi

# Set up all MCP servers (works in worktrees)
# EXPERIMENT #1213: Temporarily disabled - testing without MCP servers
# if [[ -f "$DOT_DEN/mcp/setup-all-mcp-servers.sh" ]]; then
#   echo -e "${DIVIDER}"
#   echo "Setting up MCP servers..."
#   "$DOT_DEN/mcp/setup-all-mcp-servers.sh"
# else
#   echo -e "${YELLOW}MCP server setup script not found. Skipping MCP server setup.${NC}"
# fi


# GitLab MCP authentication now handled by @zereight/mcp-gitlab package
# No additional auth setup needed beyond GITLAB_PERSONAL_ACCESS_TOKEN in ~/.bash_secrets

# GitLab MCP server works via GITLAB_PERSONAL_ACCESS_TOKEN - no glab CLI setup needed

# Generate AI provider commands from templates
if [[ -f "$DOT_DEN/utils/generate-commands.sh" ]]; then
  echo "Generating AI provider commands from templates..."
  "$DOT_DEN/utils/generate-commands.sh"
elif [[ -f "$DOT_DEN/utils/generate-claude-commands.sh" ]]; then
  # Fallback to Claude-specific script for backwards compatibility
  echo "Generating Claude commands from templates (legacy)..."
  "$DOT_DEN/utils/generate-claude-commands.sh"
else
  echo -e "${YELLOW}Command generation script not found. Skipping command generation.${NC}"
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

# Claude Code CLI setup and management
echo -e "${DIVIDER}"
echo "Setting up Claude Code CLI..."

# Setup Claude Code CLI (configure MCP servers, settings, and install if needed)
if [[ -f "$DOT_DEN/utils/configure-claude-code.sh" ]]; then
  source "$DOT_DEN/utils/configure-claude-code.sh"
  configure_claude_code || {
    echo -e "${RED}Failed to configure Claude Code CLI completely. Some features may not work.${NC}"
    echo "You can install it manually later with: npm install -g @anthropic-ai/claude-code"
  }
else
  echo -e "${RED}Claude Code configuration script not found at $DOT_DEN/utils/configure-claude-code.sh${NC}"
fi

# Symlink Claude Code settings to correct location
# Claude Code terminology: ~/.claude/settings.json = "user settings" (their term for global)
# We call these "global settings" since they apply across all your projects
# Using .claude/settings.json (not .local) prevents Claude from overwriting on startup
if [[ -f "$DOT_DEN/.claude/settings.json" ]]; then
  echo "Creating symlink for Claude Code global settings..."
  # Create ~/.claude directory if it doesn't exist
  mkdir -p "$HOME/.claude"
  # Create symlink (force to overwrite if exists)
  ln -sf "$DOT_DEN/.claude/settings.json" "$HOME/.claude/settings.json"
  echo -e "${GREEN}✓ Claude Code global settings symlinked to ~/.claude/settings.json${NC}"
else
  echo -e "${YELLOW}Warning: .claude/settings.json not found. Skipping settings symlink.${NC}"
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
      echo -e "${GREEN}✓ Node.js is already up to date (${CURRENT_NODE_VERSION})${NC}"
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

# GitHub CLI setup
echo -e "${DIVIDER}"
echo "Setting up GitHub CLI..."
if [[ -f "$DOT_DEN/utils/install-gh-cli.sh" ]]; then
    source "$DOT_DEN/utils/install-gh-cli.sh"
    setup_gh_cli || {
        echo -e "${RED}Failed to setup GitHub CLI completely. Some features may not work.${NC}"
        echo "You can install it manually later or run the setup script again."
    }
else
    echo -e "${RED}GitHub CLI installation script not found at $DOT_DEN/utils/install-gh-cli.sh${NC}"
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

# tmux setup
echo -e "${DIVIDER}"
echo "Setting up tmux..."
if [[ -f "$DOT_DEN/utils/install-tmux.sh" ]]; then
    source "$DOT_DEN/utils/install-tmux.sh"
    install_or_update_tmux || {
        echo -e "${RED}Failed to setup tmux completely. Some features may not work.${NC}"
        echo "You can install it manually later using your system's package manager."
    }
else
    echo -e "${RED}tmux installation script not found at $DOT_DEN/utils/install-tmux.sh${NC}"
fi
echo -e "${DIVIDER}"

# urlview setup (for tmux URL extraction)
echo "Setting up urlview (tmux URL extraction utility)..."
if [[ -f "$DOT_DEN/utils/install-urlview.sh" ]]; then
    source "$DOT_DEN/utils/install-urlview.sh"
    install_or_update_urlview || {
        echo -e "${YELLOW}Failed to setup urlview. tmux URL extraction may not work.${NC}"
        echo "You can install it manually: apt install urlview (Linux) or brew install urlview (macOS)"
    }
else
    echo -e "${RED}urlview installation script not found at $DOT_DEN/utils/install-urlview.sh${NC}"
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

# MCP Dashboard setup
# EXPERIMENT #1213: Temporarily disabled - testing without MCP servers/dashboard
# echo -e "${DIVIDER}"
# echo "Setting up MCP Dashboard..."
# 
# # Check if start-mcp-dashboard script exists
# if [[ -x "$DOT_DEN/bin/start-mcp-dashboard" ]]; then
#   # Use the start-mcp-dashboard script which handles all checks
#   "$DOT_DEN/bin/start-mcp-dashboard" start
#   # The script handles:
#   # - Checking if dashboard is already running
#   # - Verifying the binary exists
#   # - Starting with proper health checks
#   # - Displaying clear status messages
# else
#   echo -e "${YELLOW}start-mcp-dashboard script not found. Skipping dashboard setup.${NC}"
# fi

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Dotfiles setup complete!${NC}"
echo "Your development environment is now configured and ready to use."
echo -e "${DIVIDER}"

# Clear the error trap to prevent it from persisting in the shell session
trap - ERR

# Final debug message
echo "Debug: Setup script completed successfully"
