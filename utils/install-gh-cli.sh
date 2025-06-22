#!/bin/bash
# GitHub CLI Installation and Update Utility

# Source common logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logging.sh"

install_or_update_gh_cli() {
  log_info "Installing/updating GitHub CLI using official method..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Debian/Ubuntu-based systems
    if command -v apt &> /dev/null; then
      log_info "Using apt installation..."
      (
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update 2>/dev/null
        sudo apt install -y gh
      ) || log_warning "Failed to install/update GitHub CLI via apt. Continuing..."
    
    # For Arch-based systems
    elif command -v pacman &> /dev/null; then
      log_info "Using pacman installation..."
      (sudo pacman -Sy --noconfirm github-cli) || log_warning "Failed to install/update GitHub CLI via pacman. Continuing..."
    
    # For Fedora/RHEL-based systems
    elif command -v dnf &> /dev/null; then
      log_info "Using dnf installation..."
      (sudo dnf install -y gh) || log_warning "Failed to install/update GitHub CLI via dnf. Continuing..."
    
    # Fallback to direct binary installation
    else
      log_info "No package manager found, attempting direct binary installation..."
      (
        VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4)
        curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${VERSION#v}_linux_amd64.tar.gz"
        tar xf gh.tar.gz
        sudo cp gh_"${VERSION#v}"_linux_amd64/bin/gh /usr/local/bin/
        sudo cp -r gh_"${VERSION#v}"_linux_amd64/share/man/man1/* /usr/local/share/man/man1/ 2>/dev/null || true
        rm -rf gh_"${VERSION#v}"_linux_amd64 gh.tar.gz
      ) || log_warning "Failed to install/update GitHub CLI via binary. Continuing..."
    fi
  
  # For macOS systems
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      log_info "Using Homebrew installation..."
      (brew install gh || brew upgrade gh) || log_warning "Failed to install/update GitHub CLI via Homebrew. Continuing..."
      # Ensure Homebrew paths are loaded
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      log_error "Homebrew not found. Cannot install GitHub CLI."
      log_info "Please install Homebrew first: https://brew.sh"
      return 1
    fi
  else
    log_warning "Unsupported OS: $OSTYPE. Please install GitHub CLI manually."
    return 1
  fi
}

setup_gh_cli() {
  # Check if GitHub CLI is installed
  if command -v gh &> /dev/null; then
    CURRENT_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
    log_info "Current GitHub CLI version: $CURRENT_VERSION"
    
    # Get the latest available version from GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4 | tr -d 'v')
    
    # Check if update is needed
    if [[ -n "$LATEST_VERSION" && "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
      log_info "Newer version available: $LATEST_VERSION. Updating GitHub CLI..."
      install_or_update_gh_cli
      
      if [ $? -eq 0 ]; then
        NEW_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
        if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
          log_success "GitHub CLI updated from $CURRENT_VERSION to $NEW_VERSION"
        else
          log_warning "GitHub CLI update attempted but version remained at $CURRENT_VERSION"
        fi
      fi
    else
      log_success "GitHub CLI is already up to date ($CURRENT_VERSION)"
    fi
  else
    log_info "GitHub CLI not installed. Installing now..."
    install_or_update_gh_cli
    
    if [ $? -eq 0 ]; then
      if command -v gh &> /dev/null; then
        INSTALLED_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
        log_success "GitHub CLI installed successfully (version $INSTALLED_VERSION)"
      else
        log_error "GitHub CLI installation failed."
        return 1
      fi
    fi
  fi
  
  # Export GitHub token for MCP if gh is available
  if command -v gh &> /dev/null; then
    TOKEN=$(gh auth token 2>/dev/null)
    if [ -n "$TOKEN" ]; then
      export GITHUB_TOKEN="$TOKEN"
      log_success "GitHub token exported as GITHUB_TOKEN"
      
      # Configure Git to use GitHub CLI for authentication
      gh auth setup-git
      log_success "Git configured to use GitHub CLI for authentication"
    else
      log_warning "No GitHub token found. Please run 'gh auth login' first."
    fi
  else
    log_warning "GitHub CLI not installed. Skipping GitHub token export."
    log_info "To use GitHub MCP features, install GitHub CLI and run: export GITHUB_TOKEN=\$(gh auth token)"
    return 1
  fi
  
  return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_gh_cli
fi
