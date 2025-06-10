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
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    os_type="darwin"
  else
    echo -e "${RED}Unsupported OS: $OSTYPE. Please install Amazon Q CLI manually.${NC}"
    echo "Visit: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-getting-started-installing.html"
    return 1
  fi
  
  # Map architecture names
  local q_arch=""
  case "$arch" in
    "x86_64")
      q_arch="x86_64"
      ;;
    "aarch64")
      if [[ "$os_type" == "linux" ]]; then
        q_arch="aarch64"
      else
        q_arch="arm64"
      fi
      ;;
    "arm64")
      q_arch="arm64"
      ;;
    *)
      echo -e "${RED}Unsupported architecture: $arch${NC}"
      echo "Please install Amazon Q CLI manually for your architecture."
      return 1
      ;;
  esac
  
  # Construct download URL
  local base_url="https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest"
  local filename="q-${q_arch}-${os_type}.zip"
  local download_url="${base_url}/${filename}"
  
  echo "Downloading Amazon Q CLI for ${os_type} ${q_arch}..."
  
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
  
  # Extract the archive
  if ! unzip -q q.zip; then
    echo -e "${RED}Failed to extract Amazon Q CLI archive${NC}"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Find the installation script
  local install_script=""
  if [[ -f "q/install.sh" ]]; then
    install_script="q/install.sh"
  elif [[ -f "install.sh" ]]; then
    install_script="install.sh"
  else
    echo -e "${RED}Installation script not found in archive${NC}"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Make installation script executable and run it
  chmod +x "$install_script"
  
  echo "Running Amazon Q CLI installation..."
  if ./"$install_script" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Amazon Q CLI installed successfully${NC}"
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Verify installation
    if command -v q >/dev/null 2>&1; then
      local version=$(q --version 2>/dev/null | head -n 1 || echo "unknown")
      echo -e "${GREEN}✓ Amazon Q CLI version: $version${NC}"
      return 0
    else
      echo -e "${YELLOW}Amazon Q CLI installed but not immediately available in PATH${NC}"
      echo "You may need to restart your terminal or source your shell configuration."
      return 0
    fi
  else
    echo -e "${RED}Amazon Q CLI installation failed${NC}"
    rm -rf "$temp_dir"
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
    
    # Determine architecture
    local arch=$(uname -m)
    local download_url=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if [[ "$arch" == "x86_64" ]]; then
        download_url="https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip"
      elif [[ "$arch" == "aarch64" ]]; then
        download_url="https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-aarch64-linux.zip"
      fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      if [[ "$arch" == "x86_64" ]]; then
        download_url="https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-x86_64-darwin.zip"
      elif [[ "$arch" == "arm64" ]]; then
        download_url="https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/q-arm64-darwin.zip"
      fi
    fi
    
    if [[ -z "$download_url" ]]; then
      echo -e "${RED}Unsupported architecture: $arch on $OSTYPE. Cannot update Amazon Q automatically${NC}"
      return 1
    fi
    
    # Download and install update
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1
    
    if curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip" 2>/dev/null; then
      if unzip -o q.zip >/dev/null 2>&1; then
        if [[ -f "q/install.sh" ]]; then
          chmod +x q/install.sh
          ./q/install.sh >/dev/null 2>&1
          echo -e "${GREEN}✓ Amazon Q updated successfully${NC}"
        fi
      fi
      rm -rf q.zip q/ >/dev/null 2>&1
    fi
    
    rm -rf "$temp_dir"
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
