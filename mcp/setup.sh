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
  
  # Check for GitHub token in secrets file
  local github_token=""
  if [ -f "$SECRETS_FILE" ]; then
    # Try to extract GitHub token from secrets file
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE"; then
      github_token=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" | cut -d '=' -f2)
      log "Found GitHub token in secrets file"
    fi
  fi
  
  # If no token found and not in non-interactive mode, prompt for token
  if [ -z "$github_token" ]; then
    echo "No GitHub token found in secrets file."
    echo "A GitHub Personal Access Token is required for the GitHub MCP server."
    echo "You can create one at: https://github.com/settings/tokens"
    echo "The token needs 'repo' scope for repository access."
    
    # Only prompt if we're in an interactive shell
    if [ -t 0 ]; then
      read -p "Enter your GitHub Personal Access Token (or press Enter to skip): " github_token
      
      if [ -n "$github_token" ]; then
        echo "Adding GitHub token to secrets file..."
        echo "GITHUB_PERSONAL_ACCESS_TOKEN=$github_token" >> "$SECRETS_FILE"
        chmod 600 "$SECRETS_FILE"
      else
        echo "No token provided. GitHub MCP server will not function correctly."
      fi
    else
      echo "Running in non-interactive mode. Skipping token prompt."
      echo "GitHub MCP server will not function correctly without a token."
    fi
  fi
  
  # Copy the template configuration
  cp "$CONFIG_DIR/${persona}-mcp.json" "$HOME/.aws/amazonq/mcp.json"
  
  # Create MCP servers directory in the user's path
  mkdir -p "$HOME/mcp"
  
  # Install test MCP server
  # Remove any existing file or symlink first
  rm -f "$HOME/mcp/test-mcp-server"
  # Create symlink to the file in the repository
  ln -sf "$(dirname "$0")/servers/test-mcp-server" "$HOME/mcp/test-mcp-server"
  
  # Also update the .local/bin symlink if it exists
  if [ -L "$HOME/.local/bin/test-mcp-server" ]; then
    log "Updating existing symlink in ~/.local/bin"
    ln -sf "$(dirname "$0")/servers/test-mcp-server" "$HOME/.local/bin/test-mcp-server"
  fi
  
  # Install GitHub MCP server
  # Remove any existing file or symlink first
  rm -f "$HOME/mcp/github-mcp-server"
  
  # Check if github-mcp-server exists in the root directory
  if [ -d "$HOME/ppv/pillars/dotfiles/github-mcp-server" ]; then
    log "Building GitHub MCP server from source using Go"
    
    # Navigate to the github-mcp-server directory
    pushd "$HOME/ppv/pillars/dotfiles/github-mcp-server" > /dev/null
    
    # Kill any running instances of github-mcp-server
    pkill -f github-mcp-server || true
    
    # Build the server using Go
    if command -v go &> /dev/null; then
      log "Building with Go..."
      go build -o github-mcp-server ./cmd/github-mcp-server
      
      # Check if build was successful
      if [ -f "./github-mcp-server" ]; then
        log "GitHub MCP server built successfully"
        
        # Create symlink to the built binary
        ln -sf "$(pwd)/github-mcp-server" "$HOME/mcp/github-mcp-server"
        log "Created symlink to GitHub MCP server"
        
        # Also update the .local/bin symlink if it exists
        if [ -L "$HOME/.local/bin/github-mcp-server" ]; then
          log "Updating existing symlink in ~/.local/bin for github-mcp-server"
          ln -sf "$(pwd)/github-mcp-server" "$HOME/.local/bin/github-mcp-server"
        fi
      else
        log "Failed to build GitHub MCP server"
      fi
    else
      log "Go is not installed. Cannot build GitHub MCP server."
    fi
    
    # Return to original directory
    popd > /dev/null
  else
    log "GitHub MCP server source not found at $HOME/ppv/pillars/dotfiles/github-mcp-server"
  fi
  
  # Ensure the MCP directory is in the PATH
  if ! echo "$PATH" | grep -q "$HOME/mcp"; then
    echo "Adding $HOME/mcp to PATH in .bashrc"
    echo 'export PATH="$HOME/mcp:$PATH"' >> "$HOME/.bashrc"
    # Also add to current session
    export PATH="$HOME/mcp:$PATH"
  fi
  
  # Check if Docker is installed for GitHub MCP server
  if command -v docker &> /dev/null; then
    log "Docker is available. GitHub MCP server can be used with Docker."
    log "To use GitHub MCP server, add the following to your ~/.aws/amazonq/mcp.json:"
    log '{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
      }
    }
  }
}'
  else
    log "Docker not found. GitHub MCP server requires Docker or building from source."
    log "See https://github.com/github/github-mcp-server for installation instructions."
  fi
  
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
