#!/bin/bash

# MCP Configuration Setup Script
# This script sets up MCP configurations for different AI assistants

set -e

# Default values
ASSISTANT="amazonq"
VERBOSE=false
CONFIG_DIR="$(dirname "$0")/config-templates"
SECRETS_FILE="$HOME/.bash_secrets"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --assistant)
      ASSISTANT="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --assistant ASSISTANT  Configure MCP for the specified assistant (default: amazonq)"
      echo "  --verbose             Show verbose output"
      echo "  --help                Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Function to log messages if verbose mode is enabled
log() {
  if [ "$VERBOSE" = true ]; then
    echo "$1"
  fi
}

# Function to source secrets file if it exists
source_secrets() {
  if [ -f "$SECRETS_FILE" ]; then
    log "Sourcing secrets from $SECRETS_FILE"
    source "$SECRETS_FILE"
  else
    log "No secrets file found at $SECRETS_FILE"
  fi
}

# Setup MCP for Amazon Q
setup_amazonq() {
  log "Setting up MCP for Amazon Q"
  
  # Create directory if it doesn't exist
  mkdir -p "$HOME/.amazonq"
  
  # Copy the template configuration
  cp "$CONFIG_DIR/amazonq-mcp.json" "$HOME/.amazonq/mcp.json"
  
  log "Amazon Q MCP configuration set up successfully"
}

# Setup MCP for Claude CLI
setup_claude() {
  log "Setting up MCP for Claude CLI"
  
  # Implementation depends on Claude CLI's configuration approach
  echo "Claude CLI MCP configuration not yet implemented"
}

# Main setup logic
source_secrets

case "$ASSISTANT" in
  amazonq)
    setup_amazonq
    ;;
  claude)
    setup_claude
    ;;
  *)
    echo "Unsupported assistant: $ASSISTANT"
    exit 1
    ;;
esac

echo "MCP configuration for $ASSISTANT set up successfully"
