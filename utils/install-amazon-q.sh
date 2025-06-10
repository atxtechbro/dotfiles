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
  echo -e "${YELLOW}Amazon Q CLI not found. Installing minimal version (CLI + autocomplete, no GUI)...${NC}"
  
  # Determine architecture and OS
  local arch=$(uname -m)
  
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_amazon_q_zip "linux" "$arch"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_amazon_q_zip "darwin" "$arch"
  else
    echo -e "${RED}Unsupported OS: $OSTYPE. Please install Amazon Q CLI manually.${NC}"
    echo "Visit: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html"
    return 1
  fi
}

install_amazon_q_zip() {
  local os_type="$1"
  local arch="$2"
  
  # Map architecture names
  local q_arch=""
  case "$arch" in
    "x86_64")
      q_arch="x86_64"
      ;;
    "aarch64")
      q_arch="aarch64"
      ;;
    "arm64")
      # macOS uses arm64, but Amazon Q might use aarch64 or arm64
      q_arch="arm64"
      ;;
    *)
      echo -e "${RED}Unsupported architecture: $arch${NC}"
      echo "Please install Amazon Q CLI manually for your architecture."
      return 1
      ;;
  esac
  
  # Construct download URL for minimal installation (zip file method)
  local base_url="https://desktop-release.q.us-east-1.amazonaws.com/latest"
  local filename="q-${q_arch}-${os_type}.zip"
  local download_url="${base_url}/${filename}"
  
  echo "Downloading Amazon Q CLI minimal installation for ${os_type} ${q_arch}..."
  echo "This includes 'q' command and 'qterm' autocomplete without GUI."
  
  # Create temporary directory
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || {
    echo -e "${RED}Failed to create temporary directory${NC}"
    return 1
  }
  
  # Download Amazon Q CLI
  if ! curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip"; then
    echo -e "${YELLOW}Failed to download from $download_url${NC}"
    
    # Try alternative architecture naming for macOS
    if [[ "$os_type" == "darwin" && "$q_arch" == "arm64" ]]; then
      echo "Trying alternative architecture naming (aarch64)..."
      filename="q-aarch64-${os_type}.zip"
      download_url="${base_url}/${filename}"
      
      if ! curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip"; then
        echo -e "${RED}Failed to download Amazon Q CLI from both URLs${NC}"
        echo "Please install manually or use Homebrew: brew install --cask amazon-q"
        rm -rf "$temp_dir"
        return 1
      fi
    else
      echo -e "${RED}Failed to download Amazon Q CLI${NC}"
      echo "Please check your internet connection or install manually."
      rm -rf "$temp_dir"
      return 1
    fi
  fi
  
  # Extract and install
  if unzip -q q.zip; then
    if [[ -f "q/install.sh" ]]; then
      chmod +x q/install.sh
      echo "Running Amazon Q CLI installation..."
      if ./q/install.sh; then
        echo -e "${GREEN}✓ Amazon Q CLI minimal installation completed${NC}"
        echo -e "${GREEN}✓ Installed: 'q' command for chat and 'qterm' for autocomplete${NC}"
        
        # Verify installation
        rm -rf "$temp_dir"
        
        # Check if q command is available (may need PATH refresh)
        if command -v q >/dev/null 2>&1; then
          local version=$(q --version 2>/dev/null | head -n 1 || echo "installed")
          echo -e "${GREEN}✓ Amazon Q CLI ready: $version${NC}"
        else
          echo -e "${YELLOW}Amazon Q CLI installed to ~/.local/bin${NC}"
          echo -e "${YELLOW}You may need to restart your terminal or run: export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        fi
        
        return 0
      fi
    else
      echo -e "${RED}Installation script not found in archive${NC}"
    fi
  else
    echo -e "${RED}Failed to extract Amazon Q CLI archive${NC}"
  fi
  
  rm -rf "$temp_dir"
  return 1
}

update_amazon_q() {
  if ! command -v q >/dev/null 2>&1; then
    return 1
  fi
  
  echo "Checking for Amazon Q CLI updates..."
  
  # Check if update is available
  local update_check=$(q update 2>&1 | grep "A new version of q is available:" || echo "")
  
  if [[ -n "$update_check" ]]; then
    echo "Amazon Q update available. Installing via zip file method..."
    
    local arch=$(uname -m)
    local os_type=""
    local q_arch=""
    
    # Determine OS and architecture
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      os_type="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      os_type="darwin"
    else
      echo -e "${RED}Unsupported OS for automatic updates${NC}"
      return 1
    fi
    
    # Map architecture
    case "$arch" in
      "x86_64") q_arch="x86_64" ;;
      "aarch64") q_arch="aarch64" ;;
      "arm64") q_arch="arm64" ;;
      *)
        echo -e "${RED}Unsupported architecture: $arch${NC}"
        return 1
        ;;
    esac
    
    local base_url="https://desktop-release.q.us-east-1.amazonaws.com/latest"
    local filename="q-${q_arch}-${os_type}.zip"
    local download_url="${base_url}/${filename}"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1
    
    if curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip" 2>/dev/null; then
      if unzip -q q.zip && [[ -f "q/install.sh" ]]; then
        chmod +x q/install.sh
        ./q/install.sh >/dev/null 2>&1
        echo -e "${GREEN}✓ Amazon Q updated successfully${NC}"
      fi
    else
      # Try alternative architecture naming for macOS
      if [[ "$os_type" == "darwin" && "$q_arch" == "arm64" ]]; then
        filename="q-aarch64-${os_type}.zip"
        download_url="${base_url}/${filename}"
        if curl --proto '=https' --tlsv1.2 -sSf "$download_url" -o "q.zip" 2>/dev/null; then
          if unzip -q q.zip && [[ -f "q/install.sh" ]]; then
            chmod +x q/install.sh
            ./q/install.sh >/dev/null 2>&1
            echo -e "${GREEN}✓ Amazon Q updated successfully${NC}"
          fi
        fi
      fi
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
