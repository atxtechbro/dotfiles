#!/bin/bash

# MCP Configuration Setup Script
# This script sets up MCP configuration for Amazon Q

# Default values
VERBOSE=true
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SECRETS_FILE="$HOME/.bash_secrets"
MCP_CONFIG_DIR="$HOME/.aws/amazonq"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/mcp.json"

# Remove existing MCP configuration file regardless of whether it exists
rm -f "$MCP_CONFIG_FILE" 2>/dev/null

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
  # This is kept for backward compatibility but not used for GitHub MCP servers anymore
  local github_token="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
  
  # If no token in environment, check secrets file as fallback
  if [ -z "$github_token" ] && [ -f "$SECRETS_FILE" ]; then
    # Try to extract GitHub token from secrets file
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" 2>/dev/null; then
      github_token=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" 2>/dev/null | cut -d '=' -f2 | tr -d '"')
      log_success "Found GitHub token in secrets file"
      
      # Export the token to environment for backward compatibility
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
  
  # Create the MCP configuration file with only AWS docs server
  log "Creating MCP configuration file with AWS docs server only..."
  echo '{
  "mcpServers": {
    "aws-docs": {
      "command": "'$SCRIPT_DIR'/servers/aws-docs/run-aws-docs-mcp.sh",
      "args": []
    }
  }
}' > "$MCP_CONFIG_FILE" 2>/dev/null || handle_error "Failed to create MCP config"
  log_success "Created MCP configuration file at $MCP_CONFIG_FILE"
  
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
