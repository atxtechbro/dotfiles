#!/bin/bash

# =========================================================
# DOCKER AUTO-INSTALLER FOR MACOS AND LINUX
# =========================================================
# PURPOSE: Automatically install Docker on macOS and Linux
# This follows the "spilled coffee principle" - users should be
# fully operational after running setup without manual intervention
# =========================================================

# Source common logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logging.sh"

install_docker() {
  log_warning "Docker is not installed. Installing now..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_docker_linux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_docker_macos
  else
    log_error "Unsupported OS: $OSTYPE. Please install Docker manually."
    return 1
  fi
}

install_docker_linux() {
  # Auto-install Docker based on available package manager
  if command -v apt &> /dev/null; then
    log_info "Using apt to install Docker..."
    (sudo apt-get update && sudo apt-get install -y docker.io) || {
      log_warning "Docker installation with apt failed. Continuing anyway..."
      return 1
    }
    (sudo systemctl enable docker) || log_warning "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || log_warning "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker "$USER") || log_warning "Failed to add user to Docker group. Continuing..."
    log_success "Docker installation attempted"
  
  elif command -v pacman &> /dev/null; then
    log_info "Using pacman to install Docker..."
    (sudo pacman -Sy --noconfirm docker) || {
      log_warning "Docker installation with pacman failed. Continuing..."
      return 1
    }
    (sudo systemctl enable docker) || log_warning "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || log_warning "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker "$USER") || log_warning "Failed to add user to Docker group. Continuing..."
    log_success "Docker installation attempted"
  
  elif command -v dnf &> /dev/null; then
    log_info "Using dnf to install Docker..."
    (sudo dnf -y install docker) || {
      log_warning "Docker installation with dnf failed. Continuing..."
      return 1
    }
    (sudo systemctl enable docker) || log_warning "Failed to enable Docker service. Continuing..."
    (sudo systemctl start docker) || log_warning "Failed to start Docker service. Continuing..."
    (sudo usermod -aG docker "$USER") || log_warning "Failed to add user to Docker group. Continuing..."
    log_success "Docker installation attempted"
  
  else
    log_error "Unable to install Docker automatically on Linux."
    log_info "Please install Docker manually for your distribution."
    return 1
  fi
  
  log_info "Note: You'll need to log out and back in for group changes to take effect."
  return 0
}

install_docker_macos() {
  # Check if Homebrew is available
  if ! command -v brew &> /dev/null; then
    log_error "Homebrew is required to install Docker on macOS."
    log_info "Please ensure Homebrew is installed first."
    return 1
  fi
  
  log_info "Using Homebrew to install Docker Desktop..."
  
  # Install Docker Desktop via Homebrew cask
  if brew install --cask docker; then
    log_success "Docker Desktop installed successfully"
    
    # Start Docker Desktop application
    log_info "Starting Docker Desktop application..."
    open -a Docker
    
    # Wait for Docker daemon to be ready
    log_info "Waiting for Docker daemon to start (this may take a minute)..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
      if docker info &>/dev/null; then
        log_success "Docker daemon is ready"
        return 0
      fi
      
      echo -n "."
      sleep 2
      ((attempt++))
    done
    
    log_warning "Docker Desktop installed but daemon not ready yet."
    log_info "Docker Desktop may still be starting up. Please wait a moment and try again."
    log_info "You can check Docker status with: docker info"
    return 0
    
  else
    log_error "Failed to install Docker Desktop via Homebrew."
    log_info "Please install Docker Desktop manually from: https://www.docker.com/products/docker-desktop"
    return 1
  fi
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_docker
fi
