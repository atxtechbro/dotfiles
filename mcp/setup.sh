#!/bin/bash

# MCP Configuration Setup Script
# This script sets up MCP configurations

# Don't use set -e as it causes the script to exit on errors
# which breaks when sourced

# Default values
VERBOSE=true
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$SCRIPT_DIR/config-templates"
SECRETS_FILE="$HOME/.bash_secrets"
CONFIG_FILE="$CONFIG_DIR/mcp.json"

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
    echo "$1"
  fi
}

# Function to handle errors gracefully
handle_error() {
  echo "Warning: $1"
  # Don't exit, just continue
}

# Setup MCP for Amazon Q
setup_amazonq() {
  log "Setting up MCP for Amazon Q"
  
  # Create directory if it doesn't exist
  mkdir -p "$HOME/.aws/amazonq" || handle_error "Failed to create directory $HOME/.aws/amazonq"
  
  # Set GitHub token directly from environment variable if available
  # This simplifies the token handling and avoids issues with the secrets file
  local github_token="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
  
  # If no token in environment, check secrets file as fallback
  if [ -z "$github_token" ] && [ -f "$SECRETS_FILE" ]; then
    # Try to extract GitHub token from secrets file
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" 2>/dev/null; then
      github_token=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$SECRETS_FILE" 2>/dev/null | cut -d '=' -f2)
      log "Found GitHub token in secrets file"
      
      # Export the token to environment for MCP server to use
      export GITHUB_PERSONAL_ACCESS_TOKEN="$github_token"
    fi
  fi
  
  # If still no token, use placeholder for testing
  if [ -z "$github_token" ]; then
    log "No GitHub token found in environment or secrets file"
    echo "Setting placeholder token for testing."
    export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
    
    # Add to secrets file if it exists
    if [ -f "$SECRETS_FILE" ]; then
      echo "GITHUB_PERSONAL_ACCESS_TOKEN=placeholder_for_testing" >> "$SECRETS_FILE" 2>/dev/null || handle_error "Failed to update secrets file"
      chmod 600 "$SECRETS_FILE" 2>/dev/null || handle_error "Failed to set permissions on secrets file"
    fi
  fi
  
  # Copy the template configuration if it exists
  if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$HOME/.aws/amazonq/mcp.json" 2>/dev/null || handle_error "Failed to copy MCP config template"
  else
    handle_error "MCP config template not found: $CONFIG_FILE"
    # Create a minimal config
    echo '{
  "mcpServers": {
    "test": {
      "command": "test-mcp-server",
      "args": ["stdio"]
    },
    "github": {
      "command": "github-mcp-wrapper",
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}' > "$HOME/.aws/amazonq/mcp.json" 2>/dev/null || handle_error "Failed to create minimal MCP config"
  fi
  
  # Create MCP servers directory in the user's path
  mkdir -p "$HOME/mcp" 2>/dev/null || handle_error "Failed to create $HOME/mcp directory"
  
  # Install test MCP server
  # Remove any existing file or symlink first
  rm -f "$HOME/mcp/test-mcp-server" 2>/dev/null
  
  # Create symlink to the file in the repository if it exists
  if [ -f "$SCRIPT_DIR/servers/test-mcp-server" ]; then
    ln -sf "$SCRIPT_DIR/servers/test-mcp-server" "$HOME/mcp/test-mcp-server" 2>/dev/null || handle_error "Failed to create test-mcp-server symlink"
    log "Created symlink to test-mcp-server"
  else
    handle_error "test-mcp-server not found at $SCRIPT_DIR/servers/test-mcp-server"
  fi
  
  # Also update the .local/bin symlink if it exists
  if [ -d "$HOME/.local/bin" ]; then
    ln -sf "$SCRIPT_DIR/servers/test-mcp-server" "$HOME/.local/bin/test-mcp-server" 2>/dev/null || handle_error "Failed to create test-mcp-server symlink in .local/bin"
    log "Created symlink to test-mcp-server in .local/bin"
  fi
  
  # Install GitHub MCP server
  # Remove any existing file or symlink first
  rm -f "$HOME/mcp/github-mcp-server" 2>/dev/null
  
  # Clean up any potential old references to github-mcp-server
  log "Cleaning up any old GitHub MCP server references"
  rm -f "$HOME/.local/bin/github-mcp-server" 2>/dev/null
  rm -f "$HOME/.config/amazonq/github-mcp-server" 2>/dev/null
  rm -f "$HOME/.aws/amazonq/github-mcp-server" 2>/dev/null
  
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
      # Pass the token directly to the build environment
      GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" go build -o github-mcp-server ./cmd/github-mcp-server
      
      # Check if build was successful
      if [ -f "./github-mcp-server" ]; then
        log "GitHub MCP server built successfully"
        
        # Create symlink to the built binary
        ln -sf "$(pwd)/github-mcp-server" "$HOME/mcp/github-mcp-server"
        log "Created symlink to GitHub MCP server"
        
        # Also create a symlink in .local/bin for consistency
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(pwd)/github-mcp-server" "$HOME/.local/bin/github-mcp-server"
        log "Created symlink in ~/.local/bin for github-mcp-server"
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
  
  # Create a wrapper script that ensures the token is available
  cat > "$HOME/mcp/github-mcp-wrapper" << 'EOF'
#!/bin/bash
# Wrapper script for github-mcp-server that ensures the token is available

# Check if token is in environment
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  # Try to get from secrets file
  if [ -f "$HOME/.bash_secrets" ]; then
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets"; then
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets" | cut -d '=' -f2)
    fi
  fi
  
  # If still no token, use placeholder for testing
  if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
    echo "Warning: Using placeholder token for testing. GitHub API calls will fail." >&2
  fi
fi

# Run the actual server with the token in environment
if [ -x "$HOME/mcp/github-mcp-server" ]; then
  exec "$HOME/mcp/github-mcp-server" stdio
elif [ -x "$HOME/.local/bin/github-mcp-server" ]; then
  exec "$HOME/.local/bin/github-mcp-server" stdio
else
  echo "Error: github-mcp-server not found" >&2
  exit 1
fi
EOF
  chmod +x "$HOME/mcp/github-mcp-wrapper" 2>/dev/null || handle_error "Failed to make github-mcp-wrapper executable"
  
  # Update the MCP configuration to use the wrapper
  if [ -f "$HOME/.aws/amazonq/mcp.json" ]; then
    # Use sed to replace the github-mcp-server command with the wrapper
    sed -i 's|"github-mcp-server"|"github-mcp-wrapper"|g' "$HOME/.aws/amazonq/mcp.json" 2>/dev/null || handle_error "Failed to update MCP config"
  fi
  
  # Create debug script for Amazon Q
  cat > "$HOME/debug-amazonq-mcp.sh" << 'EOF'
#!/bin/bash
# Debug script for Amazon Q MCP issues

# Create log directory
LOG_DIR="$HOME/ppv/pillars/dotfiles/logs/mcp-tests"
mkdir -p "$LOG_DIR"

# Set environment variables for debugging
export Q_LOG_LEVEL=trace
export RUST_BACKTRACE=full

# Ensure GitHub token is available
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ] && [ -f "$HOME/.bash_secrets" ]; then
  if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets"; then
    export GITHUB_PERSONAL_ACCESS_TOKEN=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets" | cut -d '=' -f2)
  fi
fi

# If still no token, use placeholder for testing
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
  echo "Warning: Using placeholder token for testing. GitHub API calls will fail."
fi

# Generate timestamp for log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/debug_amazonq_${TIMESTAMP}.log"

# Run Amazon Q with debugging enabled
echo "Starting Amazon Q with debug logging..."
echo "Logs will be saved to $LOG_FILE"
q chat --trust-all-tools 2>&1 | tee "$LOG_FILE"

# After exit, provide instructions
echo ""
echo "Debug session completed. Log saved to: $LOG_FILE"
EOF
  chmod +x "$HOME/debug-amazonq-mcp.sh" 2>/dev/null || handle_error "Failed to make debug-amazonq-mcp.sh executable"
  
  echo "Created debug script at $HOME/debug-amazonq-mcp.sh"
  
  log "Amazon Q MCP configuration set up successfully"
}

# Setup MCP for Claude CLI
setup_claude() {
  log "Setting up MCP for Claude CLI"
  
  # Create directory if it doesn't exist
  mkdir -p "$HOME/.config/claude" 2>/dev/null || handle_error "Failed to create directory $HOME/.config/claude"
  
  # Copy the template configuration if it exists
  if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$HOME/.config/claude/mcp.json" 2>/dev/null || handle_error "Failed to copy Claude MCP config template"
  else
    handle_error "Claude MCP config template not found: $CONFIG_FILE"
  fi
  
  log "Claude CLI MCP configuration set up successfully"
}

# Main setup logic
setup_amazonq
setup_claude

echo "MCP configuration set up successfully"
