#!/bin/bash

# =========================================================
# HOMEBREW AUTO-INSTALLER FOR MACOS
# =========================================================
# PURPOSE: Automatically install Homebrew on macOS if missing
# This follows the "spilled coffee principle" - users should be
# fully operational after running setup without manual intervention
# =========================================================

# Define colors for consistent output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ensure_homebrew_on_macos() {
  # Only run on macOS
  if [[ "$OSTYPE" != "darwin"* ]]; then
    return 0
  fi

  if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found on macOS. Installing Homebrew automatically...${NC}"
    echo "This follows the 'spilled coffee principle' - you should be fully operational after setup."
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      # Apple Silicon Macs
      eval "$(/opt/homebrew/bin/brew shellenv)"
      # Add to bash_profile if not already present
      if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.bash_profile 2>/dev/null; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
      fi
    elif [[ -f "/usr/local/bin/brew" ]]; then
      # Intel Macs
      eval "$(/usr/local/bin/brew shellenv)"
      # Add to bash_profile if not already present
      if ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' ~/.bash_profile 2>/dev/null; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
      fi
    fi
    
    # Verify installation
    if command -v brew &> /dev/null; then
      echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
      return 0
    else
      echo -e "${RED}Homebrew installation failed. Please install manually.${NC}"
      echo "Visit: https://brew.sh"
      return 1
    fi
  else
    echo -e "${GREEN}✓ Homebrew is already installed${NC}"
    return 0
  fi
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ensure_homebrew_on_macos
fi
