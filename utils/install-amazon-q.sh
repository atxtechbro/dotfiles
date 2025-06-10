#!/bin/bash

# =========================================================
# AMAZON Q CLI AUTO-INSTALLER AND CONFIGURATOR
# =========================================================
# PURPOSE: Automatically install, update, and configure Amazon Q CLI
# This follows the "spilled coffee principle" - users should be
# fully operational after running setup without manual intervention
# =========================================================

# Define colors for consistent output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

install_amazon_q() {
  echo -e "${YELLOW}Amazon Q CLI not found. Installing now...${NC}"
  
  # Determine architecture and OS
  local arch=$(uname -m)
  local os_type=""
  
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os_type="linux"
    install_amazon_q_linux "$arch"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    os_type="darwin"
    install_amazon_q_macos
  else
    echo -e "${RED}Unsupported OS: $OSTYPE. Please install Amazon Q CLI manually.${NC}"
    echo "Visit: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html"
    return 1
  fi
}

install_amazon_q_linux() {
  local arch="$1"
  
  # Map architecture names for Linux
  local q_arch=""
  case "$arch" in
    "x86_64")
      q_arch="x86_64"
      ;;
    "aarch64")
      q_arch="aarch64"
      ;;
    *)
      echo -e "${RED}Unsupported architecture: $arch${NC}"
      echo "Please install Amazon Q CLI manually for your architecture."
      return 1
      ;;
  esac
  
  # Use the correct AWS download URL
  local base_url="https://desktop-release.q.us-east-1.amazonaws.com/latest"
  local filename="q-${q_arch}-linux.zip"
  local download_url="${base_url}/${filename}"
  
  echo "Downloading Amazon Q CLI for Linux ${q_arch}..."
  
  # Create temporary directory
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo -e "${RED}Failed to create temporary directory${NC}"
    return 1
  }
  
  # Download Amazon Q CLI
  if ! curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip"; then
    echo -e "${RED}Failed to download Amazon Q CLI from $download_url${NC}"
    echo "Please check your internet connection or install manually."
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Extract and install
  if unzip -q q.zip && [[ -f "q/install.sh" ]]; then
    chmod +x q/install.sh
    if ./q/install.sh; then
      echo -e "${GREEN}✓ Amazon Q CLI installed successfully${NC}"
      rm -rf "$temp_dir"
      return 0
    fi
  fi
  
  echo -e "${RED}Amazon Q CLI installation failed${NC}"
  rm -rf "$temp_dir"
  return 1
}

install_amazon_q_macos() {
  # Check if Homebrew is available
  if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is required to install Amazon Q CLI on macOS.${NC}"
    echo "Please ensure Homebrew is installed first."
    return 1
  fi
  
  echo "Installing Amazon Q CLI via Homebrew..."
  
  # Install Amazon Q CLI via Homebrew
  if brew install --cask amazon-q; then
    echo -e "${GREEN}✓ Amazon Q CLI installed successfully via Homebrew${NC}"
    
    # Verify installation
    if command -v q >/dev/null 2>&1; then
      local version=$(q --version 2>/dev/null | head -n 1 || echo "unknown")
      echo -e "${GREEN}✓ Amazon Q CLI version: $version${NC}"
      return 0
    else
      echo -e "${YELLOW}Amazon Q CLI installed but may need shell integration setup${NC}"
      echo "Please open the Amazon Q application and enable shell integrations."
      return 0
    fi
  else
    echo -e "${RED}Failed to install Amazon Q CLI via Homebrew.${NC}"
    echo "You can install manually by downloading from:"
    echo "https://desktop-release.q.us-east-1.amazonaws.com/latest/Amazon%20Q.dmg"
    return 1
  fi
}

update_amazon_q() {
  if ! command -v q >/dev/null 2>&1; then
    return 1
  fi
  
  echo "Checking for Amazon Q CLI updates..."
  
  # Check if update is available
  local update_check=$(q update 2>&1 | grep "A new version of q is available:" || echo "")
  
  if [[ -n "$update_check" ]]; then
    echo "Amazon Q update available. Installing..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # On macOS, use Homebrew for updates
      if command -v brew &> /dev/null; then
        brew upgrade --cask amazon-q || echo -e "${YELLOW}Homebrew upgrade failed, continuing...${NC}"
      else
        echo -e "${YELLOW}Homebrew not available for updates. Please update manually.${NC}"
      fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # On Linux, use the zip file method
      local arch=$(uname -m)
      local download_url=""
      
      if [[ "$arch" == "x86_64" ]]; then
        download_url="https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip"
      elif [[ "$arch" == "aarch64" ]]; then
        download_url="https://desktop-release.q.us-east-1.amazonaws.com/latest/q-aarch64-linux.zip"
      fi
      
      if [[ -n "$download_url" ]]; then
        local temp_dir=$(mktemp -d)
        cd "$temp_dir" || return 1
        
        if curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip" 2>/dev/null; then
          if unzip -q q.zip && [[ -f "q/install.sh" ]]; then
            chmod +x q/install.sh
            ./q/install.sh >/dev/null 2>&1
            echo -e "${GREEN}✓ Amazon Q updated successfully${NC}"
          fi
        fi
        
        rm -rf "$temp_dir"
      else
        echo -e "${RED}Unsupported architecture: $arch. Cannot update Amazon Q automatically${NC}"
      fi
    fi
  else
    echo -e "${GREEN}✓ Amazon Q is up to date${NC}"
  fi
}

configure_amazon_q() {
  if ! command -v q >/dev/null 2>&1; then
    return 1
  fi
  
  echo "Configuring Amazon Q settings..."
  
  # Configure settings with error handling
  q telemetry disable 2>/dev/null || echo -e "${YELLOW}Could not disable telemetry${NC}"
  q settings chat.editMode vi 2>/dev/null || echo -e "${YELLOW}Could not set edit mode${NC}"
  q settings chat.defaultModel claude-4-sonnet 2>/dev/null || echo -e "${YELLOW}Could not set default model${NC}"
  q settings mcp.noInteractiveTimeout 5000 2>/dev/null || echo -e "${YELLOW}Could not set MCP timeout${NC}"
  
  echo -e "${GREEN}✓ Amazon Q configuration complete${NC}"
}

setup_amazon_q() {
  # Check if Amazon Q CLI is already installed
  if command -v q >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Amazon Q CLI is already installed${NC}"
    
    # Check for updates
    update_amazon_q
    
    # Configure settings
    configure_amazon_q
    
    return 0
  else
    # Install Amazon Q CLI
    if install_amazon_q; then
      # Configure after successful installation
      configure_amazon_q
      return 0
    else
      return 1
    fi
  fi
}

# If script is executed directly (not sourced), run the setup function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_amazon_q
fi
