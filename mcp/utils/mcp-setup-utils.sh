#!/bin/bash

# =========================================================
# MCP SETUP UTILITY FUNCTIONS
# =========================================================
# PURPOSE: Shared utility functions for MCP server setup scripts
# This script provides common functions used across multiple MCP setup scripts
# to reduce code duplication and ensure consistent behavior.
# =========================================================

# Check if Docker is installed
check_docker_installed() {
  if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first." >&2
    exit 1
  fi
  
  # Ensure Docker is running
  UTILS_DIR="$(dirname "$(dirname "$0")")/utils"
  if [ -f "$UTILS_DIR/ensure-docker-running.sh" ]; then
    source "$UTILS_DIR/ensure-docker-running.sh"
  else
    if ! docker info >/dev/null 2>&1; then
      echo "Error: Docker is not running. Please start Docker and try again." >&2
      exit 1
    fi
  fi
}
# Check if we're in the dotfiles repository
check_dotfiles_repo() {
  if [ ! -d "$(dirname "$0")/../.git" ] && [ ! -d "$(dirname "$0")/../../.git" ]; then
    echo "Error: This script must be run from the dotfiles repository." >&2
    exit 1
  fi
}

# Get the repository root directory
get_repo_root() {
  # Handle both direct calls and calls from subdirectories
  if [ -d "$(dirname "$0")/../.git" ]; then
    echo "$(cd "$(dirname "$0")/.." && pwd)"
  else
    echo "$(cd "$(dirname "$0")/../.." && pwd)"
  fi
}

# Clone or update the MCP servers repository
setup_mcp_servers_repo() {
  local repo_url="${1:-https://github.com/atxtechbro/mcp-servers.git}"
  local repo_dir="${2:-/tmp/mcp-servers}"
  
  if [ ! -d "$repo_dir" ]; then
    echo "Cloning MCP servers repository..."
    git clone "$repo_url" "$repo_dir"
  else
    echo "Updating MCP servers repository..."
    cd "$repo_dir" && git pull
  fi
}

# Build Docker image for a specific MCP server
build_mcp_docker_image() {
  local server_name="$1"
  local repo_dir="${2:-/tmp/mcp-servers}"
  
  echo "Building Docker image for ${server_name} MCP server..."
  cd "$repo_dir" && docker build -t "mcp/${server_name}" -f "src/${server_name}/Dockerfile" .
}

# Update .bash_secrets.example with API credentials template
update_secrets_template() {
  local repo_root="$1"
  local var_name="$2"
  local section_title="$3"
  local comment="$4"
  local example="$5"
  
  local secrets_example="${repo_root}/.bash_secrets.example"
  
  if ! grep -q "$var_name" "$secrets_example"; then
    echo "" >> "$secrets_example"
    echo "# ==== ${section_title} ====" >> "$secrets_example"
    echo "# ${comment}" >> "$secrets_example"
    echo "# ${example}" >> "$secrets_example"
    
    echo "Updated .bash_secrets.example with ${section_title} template"
  fi
}

# Print setup completion message
print_setup_complete() {
  local server_name="$1"
  local env_vars="$2"
  local tools="$3"
  
  echo ""
  echo "Setup complete! To use the ${server_name} MCP server:"
  
  if [ -n "$env_vars" ]; then
    echo "1. Add your credentials to ~/.bash_secrets:"
    echo "$env_vars"
    echo "2. Restart your Amazon Q CLI or other MCP client"
  else
    echo "1. Restart your Amazon Q CLI or other MCP client"
  fi
  
  echo ""
  echo "The ${server_name} MCP server provides these tools:"
  echo "$tools"
}
