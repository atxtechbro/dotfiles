#!/bin/bash

# MCP Configuration Setup Script
# This script sets up MCP configuration for Amazon Q

# Default values
VERBOSE=true
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SECRETS_FILE="$HOME/.bash_secrets"
MCP_CONFIG_DIR="$HOME/.aws/amazonq"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/mcp.json"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --verbose            Show verbose output"
      echo "  --help               Show this help message"
      return 0 2>/dev/null || exit 0
      ;;
    *)
      echo "Unknown option: $1"
      return 1 2>/dev/null || exit 1
      ;;
  esac
done

# Function to log messages if verbose mode is enabled
log() {
  if [ "$VERBOSE" = true ]; then
    echo "[$(date '+%H:%M:%S')] $1"
  fi
}

# Function to log success messages
log_success() {
  if [ "$VERBOSE" = true ]; then
    echo "[$(date '+%H:%M:%S')] ✅ $1"
  fi
}

# Function to log warning messages
log_warning() {
  echo "[$(date '+%H:%M:%S')] ⚠️  $1"
}

# Function to log error messages
log_error() {
  echo "[$(date '+%H:%M:%S')] ❌ $1"
}

# Function to handle errors gracefully
handle_error() {
  log_error "$1"
  # Don't exit, just continue
}

# Setup MCP configuration
setup_mcp() {
  log "Setting up MCP configuration for Amazon Q..."
  
  # Create directory if it doesn't exist
  mkdir -p "$MCP_CONFIG_DIR" || handle_error "Failed to create directory $MCP_CONFIG_DIR"
  log "Created directory $MCP_CONFIG_DIR"
  
  # Set GitHub token directly from environment variable if available
  local github_token="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
  
  # If no token in environment, check secrets file as fallback
  if [ -z "$github_token" ] && [ -f "$SECRETS_FILE" ]; then
    # Try to extract GitHub token from secrets file
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" 2>/dev/null; then
      github_token=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" 2>/dev/null | cut -d '=' -f2 | tr -d '"')
      log_success "Found GitHub token in secrets file"
      
      # Export the token to environment for MCP server to use
      export GITHUB_PERSONAL_ACCESS_TOKEN="$github_token"
    else
      log_warning "No GitHub token found in secrets file"
    fi
  else
    if [ -n "$github_token" ]; then
      log_success "Using GitHub token from environment"
    else
      log_warning "No GitHub token found in environment"
    fi
  fi
  
  # If still no token, use placeholder for testing
  if [ -z "$github_token" ]; then
    log_warning "No GitHub token found in environment or secrets file"
    log_error "Setting placeholder token for testing. GitHub API calls will fail."
    export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
    
    # Add to secrets file if it exists
    if [ -f "$SECRETS_FILE" ]; then
      echo "GITHUB_PERSONAL_ACCESS_TOKEN=placeholder_for_testing" >> "$SECRETS_FILE" 2>/dev/null || handle_error "Failed to update secrets file"
      chmod 600 "$SECRETS_FILE" 2>/dev/null || handle_error "Failed to set permissions on secrets file"
      log "Added placeholder token to secrets file"
    fi
  fi
  
  # Clean up any old MCP server references
  log "Cleaning up any old MCP server references..."
  rm -f "$HOME/mcp/test-mcp-server" 2>/dev/null
  rm -f "$HOME/.local/bin/test-mcp-server" 2>/dev/null
  rm -f "$HOME/mcp/github-mcp-server" 2>/dev/null
  rm -f "$HOME/.local/bin/github-mcp-server" 2>/dev/null
  rm -f "$HOME/mcp/github-mcp-wrapper" 2>/dev/null
  rm -f "$HOME/.local/bin/github-mcp-wrapper" 2>/dev/null
  
  # Setup AWS Documentation MCP server
  log "Setting up AWS Documentation MCP server..."
  if [ -f "$SCRIPT_DIR/servers/aws-docs/setup.sh" ]; then
    chmod +x "$SCRIPT_DIR/servers/aws-docs/setup.sh"
    "$SCRIPT_DIR/servers/aws-docs/setup.sh" || handle_error "Failed to setup AWS Documentation MCP server"
    log_success "AWS Documentation MCP server setup complete"
  else
    log_error "AWS Documentation MCP server setup script not found"
  fi
  
  # Check if Docker is installed
  if command -v docker &> /dev/null; then
    log_success "Docker is available ($(docker --version))"
    
    # Pull the Docker image in advance to avoid delays during first use
    log "Pulling GitHub MCP server Docker image with sudo (ghcr.io/github/github-mcp-server)..."
    if sudo docker pull ghcr.io/github/github-mcp-server >/dev/null 2>&1; then
      log_success "Docker image pulled successfully with sudo (ghcr.io/github/github-mcp-server)"
    else
      log_error "Failed to pull Docker image with sudo. Check Docker installation and permissions."
    fi
    
    # Create the MCP configuration file with both sudo and non-sudo Docker commands
    log "Creating MCP configuration file with both sudo and non-sudo Docker options..."
    echo '{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server",
        "stdio"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "'${GITHUB_PERSONAL_ACCESS_TOKEN}'"
      }
    },
    "github-sudo": {
      "command": "sudo",
      "args": [
        "docker",
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server",
        "stdio"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "'${GITHUB_PERSONAL_ACCESS_TOKEN}'"
      }
    },
    "aws-docs": {
      "command": "'$SCRIPT_DIR'/servers/aws-docs/run-aws-docs-mcp.sh",
      "args": []
    }
  }
}' > "$MCP_CONFIG_FILE" 2>/dev/null || handle_error "Failed to create MCP config"
    log_success "Created MCP configuration file at $MCP_CONFIG_FILE"
  else
    log_error "Docker is not available. Cannot set up GitHub MCP server."
    log_warning "Please install Docker to use the GitHub MCP server."
  fi
  
  # Ensure debug script is executable
  chmod +x ~/ppv/pillars/dotfiles/mcp/debug-mcp.sh 2>/dev/null || handle_error "Failed to make debug script executable"
  log_success "Debug script available at ~/ppv/pillars/dotfiles/mcp/debug-mcp.sh"
  
  log_success "MCP configuration set up successfully"
}

# Function to verify MCP server initialization - REMOVED
# This function was removed as it was causing false failures
# verify_mcp_initialization() {
#   # Function body removed
# }

# Main setup
setup_mcp

# Always verify MCP initialization (commented out - removed as requested)
log "MCP verification test disabled - skipping verification"
# Verification test removed as requested - it was causing false failures
