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
  log_warning "Docker missing. Installing..."
  
  # Determine OS type for installation
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_docker_linux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_docker_macos
  else
    log_error "Unsupported OS: $OSTYPE"
    return 1
  fi
}

install_docker_linux() {
  # Auto-install Docker based on available package manager
  if command -v apt &> /dev/null; then
    log_info "Using apt..."
    if ! (sudo apt-get update && sudo apt-get install -y docker.io); then
      log_error "apt install failed"
      return 1
    fi
  elif command -v pacman &> /dev/null; then
    log_info "Using pacman..."
    if ! (sudo pacman -Sy --noconfirm docker); then
      log_error "pacman install failed"
      return 1
    fi
  elif command -v dnf &> /dev/null; then
    log_info "Using dnf..."
    if ! (sudo dnf -y install docker); then
      log_error "dnf install failed"
      return 1
    fi
  else
    log_error "No supported package manager"
    return 1
  fi
  
  # Configure Docker service
  (sudo systemctl enable docker) || log_warning "Enable failed"
  (sudo systemctl start docker) || log_warning "Start failed"
  (sudo usermod -aG docker "$USER") || log_warning "Group add failed"
  
  log_success "Docker installed"
  log_info "Logout/login for group changes"
  return 0
}

install_docker_macos() {
  # Check if Homebrew is available
  if ! command -v brew &> /dev/null; then
    log_error "Homebrew required"
    return 1
  fi
  
  log_info "Installing via Homebrew..."
  
  # Install Docker Desktop via Homebrew cask
  if brew install --cask docker; then
    log_success "Docker Desktop installed"
    
    # Start Docker Desktop application
    log_info "Starting Docker Desktop..."
    open -a Docker
    
    # Wait for Docker daemon to be ready
    log_info "Waiting for daemon..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
      if docker info &>/dev/null; then
        log_success "Daemon ready"
        return 0
      fi
      
      echo -n "."
      sleep 2
      ((attempt++))
    done
    
    log_warning "Daemon not ready yet"
    log_info "Check status: docker info"
    return 0
    
  else
    log_error "Homebrew install failed"
    return 1
  fi
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_docker
fi
