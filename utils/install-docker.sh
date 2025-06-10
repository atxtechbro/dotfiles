#!/bin/bash

# =========================================================
# DOCKER AUTO-INSTALLER FOR MACOS AND LINUX
# =========================================================
# PURPOSE: Automatically install Docker on macOS and Linux
# This follows the "spilled coffee principle" - users should be
# fully operational after running setup without manual intervention
# =========================================================

# Define colors for consistent output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

install_docker() {
  echo -e "${YELLOW}Docker is not installed. Installing now...${NC}"
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_docker_linux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_docker_macos
  else
    echo -e "${RED}Unsupported OS: $OSTYPE. Please install Docker manually.${NC}"
    return 1
  fi
}

install_docker_linux() {
  # Auto-install Docker based on available package manager
  if command -v apt &> /dev/null; then
    echo "Using apt to install Docker..."
    (sudo apt-get update && sudo apt-get install -y docker.io) || {
      echo -e "${YELLOW}Docker installation with apt failed. Continuing anyway...${NC}"
      return 1
    }
    (sudo systemctl enable docker) || echo "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || echo "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker "$USER") || echo "Failed to add user to Docker group. Continuing..."
    echo -e "${GREEN}✓ Docker installation attempted${NC}"
  
  elif command -v pacman &> /dev/null; then
    echo "Using pacman to install Docker..."
    (sudo pacman -Sy --noconfirm docker) || {
      echo "Docker installation with pacman failed. Continuing..."
      return 1
    }
    (sudo systemctl enable docker) || echo "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || echo "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker "$USER") || echo "Failed to add user to Docker group. Continuing..."
    echo -e "${GREEN}✓ Docker installation attempted${NC}"
  
  elif command -v dnf &> /dev/null; then
    echo "Using dnf to install Docker..."
    (sudo dnf -y install docker) || {
      echo "Docker installation with dnf failed. Continuing..."
      return 1
    }
    (sudo systemctl enable docker) || echo "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || echo "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker "$USER") || echo "Failed to add user to Docker group. Continuing..."
    echo -e "${GREEN}✓ Docker installation attempted${NC}"
  
  else
    echo -e "${RED}Unable to install Docker automatically on Linux.${NC}"
    echo "Please install Docker manually for your distribution."
    return 1
  fi
  
  echo "Note: You'll need to log out and back in for group changes to take effect."
  return 0
}

install_docker_macos() {
  # Check if Homebrew is available
  if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is required to install Docker on macOS.${NC}"
    echo "Please ensure Homebrew is installed first."
    return 1
  fi
  
  echo "Using Homebrew to install Docker Desktop..."
  
  # Install Docker Desktop via Homebrew cask
  if brew install --cask docker; then
    echo -e "${GREEN}✓ Docker Desktop installed successfully${NC}"
    
    # Start Docker Desktop application
    echo "Starting Docker Desktop application..."
    open -a Docker
    
    # Wait for Docker daemon to be ready
    echo "Waiting for Docker daemon to start (this may take a minute)..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
      if docker info &>/dev/null; then
        echo -e "${GREEN}✓ Docker daemon is ready${NC}"
        return 0
      fi
      
      echo -n "."
      sleep 2
      ((attempt++))
    done
    
    echo -e "\n${YELLOW}Docker Desktop installed but daemon not ready yet.${NC}"
    echo "Docker Desktop may still be starting up. Please wait a moment and try again."
    echo "You can check Docker status with: docker info"
    return 0
    
  else
    echo -e "${RED}Failed to install Docker Desktop via Homebrew.${NC}"
    echo "Please install Docker Desktop manually from: https://www.docker.com/products/docker-desktop"
    return 1
  fi
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_docker
fi
