#!/bin/bash
# Google Chrome Installation and Update Utility

# Source common logging functions
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source "${SCRIPT_DIR}/logging.sh"

install_or_update_chrome() {
  log_info "Installing Google Chrome..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Debian/Ubuntu-based systems
    if command -v apt &> /dev/null; then
      log_info "Using apt..."
      (
        # Add Google Chrome repository
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google.asc >/dev/null
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
        sudo apt update 2>/dev/null
        sudo apt install -y google-chrome-stable
      ) || log_warning "apt install failed"
    
    # For Arch-based systems
    elif command -v pacman &> /dev/null; then
      log_info "Using AUR helper (yay)..."
      if command -v yay &> /dev/null; then
        (yay -Sy --noconfirm google-chrome) || log_warning "yay install failed"
      else
        log_warning "yay not found. Install from AUR manually or use chromium instead."
        (sudo pacman -Sy --noconfirm chromium) || log_warning "chromium install failed"
      fi
    
    # For Fedora/RHEL-based systems
    elif command -v dnf &> /dev/null; then
      log_info "Using dnf..."
      (
        sudo dnf install -y fedora-workstation-repositories
        sudo dnf config-manager --set-enabled google-chrome
        sudo dnf install -y google-chrome-stable
      ) || log_warning "dnf install failed"
    
    # Fallback - download .deb directly
    else
      log_info "Direct .deb install..."
      (
        wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb
        # Fix dependencies if needed
        sudo apt-get install -f -y
        rm -f /tmp/google-chrome-stable_current_amd64.deb
      ) || log_warning "Direct install failed"
    fi
  
  # For macOS systems
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      log_info "Using Homebrew..."
      (brew install --cask google-chrome || brew upgrade --cask google-chrome) || log_warning "Homebrew install failed"
    else
      log_error "Homebrew not found"
      return 1
    fi
  else
    log_warning "Unsupported OS: $OSTYPE"
    return 1
  fi
}

setup_chrome() {
  # Check if Google Chrome is installed
  if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
    # Try to get the current version
    if command -v google-chrome &> /dev/null; then
      CHROME_CMD="google-chrome"
    else
      CHROME_CMD="google-chrome-stable"
    fi
    
    CURRENT_VERSION=$($CHROME_CMD --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' || echo "unknown")
    log_info "Current: $CURRENT_VERSION"
    
    # Chrome auto-updates through its own mechanism on most systems
    # But we can trigger a repository update to ensure latest version is available
    if [[ "$OSTYPE" == "linux-gnu"* ]] && command -v apt &> /dev/null; then
      log_info "Checking for updates via apt..."
      sudo apt update 2>/dev/null
      
      # Check if an update is available
      UPDATE_AVAILABLE=$(apt list --upgradable 2>/dev/null | grep -i google-chrome || true)
      if [[ -n "$UPDATE_AVAILABLE" ]]; then
        log_info "Update available, installing..."
        
        # Check if Chrome is running and warn user
        if pgrep -x "chrome" > /dev/null || pgrep -x "google-chrome" > /dev/null; then
          log_warning "Chrome is currently running. Please close it for the update to take effect."
          echo "You can close Chrome and run this again, or the update will apply next time Chrome starts."
        fi
        
        # Force update
        sudo apt update 2>/dev/null
        sudo apt install -y --only-upgrade google-chrome-stable
        
        # Get new version (from package info since Chrome might still show old version until restarted)
        NEW_VERSION=$(apt list --installed 2>/dev/null | grep google-chrome-stable | cut -d' ' -f2 | cut -d'-' -f1)
        log_success "Updated package: $CURRENT_VERSION → $NEW_VERSION"
        log_info "Restart Chrome to use the new version"
      else
        log_success "Already latest: $CURRENT_VERSION"
      fi
    else
      log_success "Chrome installed: $CURRENT_VERSION (auto-updates enabled)"
    fi
  else
    log_info "Installing Chrome..."
    install_or_update_chrome
    
    if [ $? -eq 0 ]; then
      if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
        if command -v google-chrome &> /dev/null; then
          CHROME_CMD="google-chrome"
        else
          CHROME_CMD="google-chrome-stable"
        fi
        INSTALLED_VERSION=$($CHROME_CMD --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' || echo "unknown")
        log_success "Installed: $INSTALLED_VERSION"
      else
        log_error "Install failed"
        return 1
      fi
    fi
  fi
  
  return 0
}

# Main execution
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]:-}" && "$0" != "bash" && "$0" != "zsh" && "$0" != "-bash" && "$0" != "-zsh" ]]; then
  setup_chrome
fi