#!/bin/bash

# MCP Configuration Setup Script
# This script sets up MCP configurations for different personas

set -e

# Default values
PERSONA="personal"
VERBOSE=false
CONFIG_DIR="$(dirname "$0")/config-templates"
SECRETS_FILE="$HOME/.bash_secrets"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --persona)
      PERSONA="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --persona PERSONA    Configure MCP for the specified persona (default: personal)"
      echo "                       Available personas: personal, company"
      echo "  --verbose            Show verbose output"
      echo "  --help               Show this help message"
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

# Secrets are assumed to be already loaded into the system

# Setup MCP for Amazon Q
setup_amazonq() {
  local persona=$1
  log "Setting up MCP for Amazon Q with persona: $persona"
  
  # Create directory if it doesn't exist
  mkdir -p "$HOME/.aws/amazonq"
  
  # Copy the template configuration
  cp "$CONFIG_DIR/${persona}-mcp.json" "$HOME/.aws/amazonq/mcp.json"
  
  # Create test MCP server in the user's path
  mkdir -p "$HOME/mcp"
  # Remove any existing file or symlink first
  rm -f "$HOME/mcp/test-mcp-server"
  # Copy the file and make it executable
  cp "$(dirname "$0")/servers/bin/test-mcp-server" "$HOME/mcp/test-mcp-server"
  chmod +x "$HOME/mcp/test-mcp-server"
  
  # Install GitHub MCP server
  log "Installing GitHub MCP server..."
  npm install -g @github/github-mcp-server
  
  # Create debug script for Amazon Q
  cat > "$HOME/debug-amazonq-mcp.sh" << 'EOF'
#!/bin/bash
# Debug script for Amazon Q MCP issues

# Create log directory
LOG_DIR="/tmp/amazonq-mcp-logs"
mkdir -p "$LOG_DIR"

# Set environment variables for debugging
export Q_LOG_LEVEL=trace
export TMPDIR="$LOG_DIR"

# Run Amazon Q with debugging enabled
echo "Starting Amazon Q with debug logging..."
echo "Logs will be available in $LOG_DIR"
q chat

# After exit, provide instructions
echo ""
echo "To view logs, run: less $LOG_DIR/qlog"
EOF
  chmod +x "$HOME/debug-amazonq-mcp.sh"
  
  echo "Created debug script at $HOME/debug-amazonq-mcp.sh"
  
  log "Amazon Q MCP configuration set up successfully with $persona persona"
}

# Setup MCP for Claude CLI
setup_claude() {
  local persona=$1
  log "Setting up MCP for Claude CLI with persona: $persona"
  
  # Create directory if it doesn't exist
  mkdir -p "$HOME/.config/claude"
  
  # Copy the template configuration
  cp "$CONFIG_DIR/${persona}-mcp.json" "$HOME/.config/claude/mcp.json"
  
  log "Claude CLI MCP configuration set up successfully with $persona persona"
}

# Main setup logic

# Validate persona
if [ ! -f "$CONFIG_DIR/${PERSONA}-mcp.json" ]; then
  echo "Error: Persona '$PERSONA' not found. Available personas:"
  ls -1 "$CONFIG_DIR/" | grep -o "^.*-mcp.json" | sed 's/-mcp.json//' | sed 's/^/  - /'
  exit 1
fi

# Setup for all supported assistants
setup_amazonq "$PERSONA"
setup_claude "$PERSONA"

echo "MCP configuration set up successfully with $PERSONA persona"
