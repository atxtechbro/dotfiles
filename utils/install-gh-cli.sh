#!/bin/bash
# GitHub CLI Installation and Update Utility

# Source common utilities
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source "${SCRIPT_DIR}/logging.sh"
source "${SCRIPT_DIR}/version-utils.sh"

install_or_update_gh_cli() {
  log_info "Installing GitHub CLI..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Debian/Ubuntu-based systems
    if command -v apt &> /dev/null; then
      log_info "Using apt..."
      (
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update 2>/dev/null
        sudo apt install -y gh
      ) || log_warning "apt install failed"
    
    # For Arch-based systems
    elif command -v pacman &> /dev/null; then
      log_info "Using pacman..."
      (sudo pacman -Sy --noconfirm github-cli) || log_warning "pacman install failed"
    
    # For Fedora/RHEL-based systems
    elif command -v dnf &> /dev/null; then
      log_info "Using dnf..."
      (sudo dnf install -y gh) || log_warning "dnf install failed"
    
    # Fallback to direct binary installation
    else
      log_info "Direct binary install..."
      (
        VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4)
        curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${VERSION#v}_linux_amd64.tar.gz"
        tar xf gh.tar.gz
        sudo cp gh_"${VERSION#v}"_linux_amd64/bin/gh /usr/local/bin/
        sudo cp -r gh_"${VERSION#v}"_linux_amd64/share/man/man1/* /usr/local/share/man/man1/ 2>/dev/null || true
        rm -rf gh_"${VERSION#v}"_linux_amd64 gh.tar.gz
      ) || log_warning "Binary install failed"
    fi
  
  # For macOS systems
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      log_info "Using Homebrew..."
      (brew install gh || brew upgrade gh) || log_warning "Homebrew install failed"
      # Ensure Homebrew paths are loaded
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      log_error "Homebrew not found"
      return 1
    fi
  else
    log_warning "Unsupported OS: $OSTYPE"
    return 1
  fi
}

setup_gh_cli() {
  # Check if GitHub CLI is installed
  if command -v gh &> /dev/null; then
    CURRENT_VERSION=$(extract_version "gh" "$(gh --version)")
    log_info "Current: $CURRENT_VERSION"
    
    # Get the latest available version from GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4 | tr -d 'v')
    
    # Check if update is needed using semantic version comparison
    if [[ -n "$LATEST_VERSION" ]]; then
      VERSION_STATUS=$(version_compare "$CURRENT_VERSION" "$LATEST_VERSION")
      if [[ "$VERSION_STATUS" == "older" ]]; then
      log_info "Updating to: $LATEST_VERSION"
      install_or_update_gh_cli
      
      if [ $? -eq 0 ]; then
        NEW_VERSION=$(extract_version "gh" "$(gh --version)")
        UPDATE_STATUS=$(version_compare "$CURRENT_VERSION" "$NEW_VERSION")
        if [[ "$UPDATE_STATUS" == "older" ]]; then
          log_success "Updated: $CURRENT_VERSION → $NEW_VERSION"
        else
          log_warning "Update failed, still: $CURRENT_VERSION"
        fi
      fi
      else
      log_success "Already latest: $CURRENT_VERSION"
    fi
  else
    log_info "Installing gh..."
    install_or_update_gh_cli
    
    if [ $? -eq 0 ]; then
      if command -v gh &> /dev/null; then
        INSTALLED_VERSION=$(gh --version | head -n 1 | cut -d' ' -f3)
        log_success "Installed: $INSTALLED_VERSION"
      else
        log_error "Install failed"
        return 1
      fi
    fi
  fi
  
  # Export GitHub token for MCP if gh is available
  if command -v gh &> /dev/null; then
    TOKEN=$(gh auth token 2>/dev/null)
    if [ -n "$TOKEN" ]; then
      export GITHUB_TOKEN="$TOKEN"
      log_success "Token exported"
      
      # Configure Git to use GitHub CLI for authentication
      gh auth setup-git
      log_success "Git auth configured"
    else
      log_warning "No token. Run: gh auth login"
    fi
  else
    log_warning "gh not installed"
    return 1
  fi
  
  return 0
}

# Main execution
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]:-}" && "$0" != "bash" && "$0" != "zsh" && "$0" != "-bash" && "$0" != "-zsh" ]]; then
  setup_gh_cli
fi
