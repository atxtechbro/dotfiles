#!/bin/bash
# GitHub CLI Installation and Update Utility

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_or_update_gh_cli() {
  echo "Installing/updating GitHub CLI using official method..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Debian/Ubuntu-based systems
    if command -v apt &> /dev/null; then
      echo "Using apt installation..."
      (
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
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
      echo "No package manager found, attempting direct binary installation..."
      (
        VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4)
        curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${VERSION#v}_linux_amd64.tar.gz"
        tar xf gh.tar.gz
        sudo cp gh_"${VERSION#v}"_linux_amd64/bin/gh /usr/local/bin/
        sudo cp -r gh_"${VERSION#v}"_linux_amd64/share/man/man1/* /usr/local/share/man/man1/ 2>/dev/null || true
        rm -rf gh_"${VERSION#v}"_linux_amd64 gh.tar.gz
      ) || echo -e "${YELLOW}Failed to install/update GitHub CLI via binary. Continuing...${NC}"
    fi
  
  # For macOS systems
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      echo "Using Homebrew installation..."
      (brew install gh || brew upgrade gh) || echo -e "${YELLOW}Failed to install/update GitHub CLI via Homebrew. Continuing...${NC}"
      # Ensure Homebrew paths are loaded
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo -e "${RED}Homebrew not found. Cannot install GitHub CLI.${NC}"
      echo "Please install Homebrew first: https://brew.sh"
      return 1
    fi
  else
    echo -e "${YELLOW}Unsupported OS: $OSTYPE. Please install GitHub CLI manually.${NC}"
    return 1
  fi
}

setup_gh_cli() {
  echo "Setting up GitHub CLI..."
  
  # Check if GitHub CLI is installed
  if command -v gh &> /dev/null; then
    CURRENT_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
    echo "Current GitHub CLI version: $CURRENT_VERSION"
    
    # Get the latest available version from GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4 | tr -d 'v')
    
    # Check if update is needed
    if [[ -n "$LATEST_VERSION" && "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
      echo "Newer version available: $LATEST_VERSION. Updating GitHub CLI..."
      install_or_update_gh_cli
      
      if [ $? -eq 0 ]; then
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
    
    if [ $? -eq 0 ]; then
      if command -v gh &> /dev/null; then
        INSTALLED_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
        echo -e "${GREEN}✓ GitHub CLI installed successfully (version $INSTALLED_VERSION)${NC}"
      else
        echo -e "${RED}GitHub CLI installation failed.${NC}"
        return 1
      fi
    fi
  fi
  
  # Export GitHub token for MCP if gh is available
  if command -v gh &> /dev/null; then
    TOKEN=$(gh auth token 2>/dev/null)
    if [ -n "$TOKEN" ]; then
      export GITHUB_TOKEN="$TOKEN"
      echo -e "${GREEN}✓ GitHub token exported as GITHUB_TOKEN${NC}"
      
      # Configure Git to use GitHub CLI for authentication
      gh auth setup-git
      echo -e "${GREEN}✓ Git configured to use GitHub CLI for authentication${NC}"
    else
      echo -e "${YELLOW}No GitHub token found. Please run 'gh auth login' first.${NC}"
    fi
  else
    echo -e "${YELLOW}GitHub CLI not installed. Skipping GitHub token export.${NC}"
    echo "To use GitHub MCP features, install GitHub CLI and run: export GITHUB_TOKEN=\$(gh auth token)"
    return 1
  fi
  
  # Install GitHub CLI extensions
  if [[ -f "${DOT_DEN:-$HOME/ppv/pillars/dotfiles}/utils/install-gh-extensions.sh" ]]; then
    source "${DOT_DEN:-$HOME/ppv/pillars/dotfiles}/utils/install-gh-extensions.sh"
    setup_gh_extensions || {
      echo -e "${YELLOW}Failed to setup some GitHub CLI extensions${NC}"
    }
  else
    echo -e "${YELLOW}GitHub CLI extensions script not found${NC}"
  fi
  
  return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_gh_cli
fi
