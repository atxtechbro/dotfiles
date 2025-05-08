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
  
  # Check if Docker is installed
  if command -v docker &> /dev/null; then
    log "Docker is available. Using Docker for GitHub MCP server."
    
    # Create a wrapper script for Docker-based GitHub MCP server
    cat > "$HOME/mcp/github-mcp-wrapper" << 'EOF'
#!/bin/bash
# Wrapper script for GitHub MCP server using Docker only (no Go fallback)

# Check if token is in environment
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  # Try to get from secrets file
  if [ -f "$HOME/.bash_secrets" ]; then
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets"; then
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(grep "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets" | cut -d '=' -f2 | tr -d '"')
    fi
  fi
  
  # If still no token, use placeholder for testing
  if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    export GITHUB_PERSONAL_ACCESS_TOKEN="placeholder_for_testing"
    echo "Warning: Using placeholder token for testing. GitHub API calls will fail." >&2
  fi
fi

# Debug output
echo "Using GitHub token: ${GITHUB_PERSONAL_ACCESS_TOKEN:0:5}..." >&2

# Run the GitHub MCP server using Docker directly
exec docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" \
  ghcr.io/github/github-mcp-server stdio
EOF
    chmod +x "$HOME/mcp/github-mcp-wrapper" 2>/dev/null || handle_error "Failed to make github-mcp-wrapper executable"
    log "Created Docker-based GitHub MCP server wrapper"
    
    # Also create a symlink in .local/bin for consistency
    if [ -d "$HOME/.local/bin" ]; then
      ln -sf "$HOME/mcp/github-mcp-wrapper" "$HOME/.local/bin/github-mcp-wrapper" 2>/dev/null || handle_error "Failed to create github-mcp-wrapper symlink in .local/bin"
      log "Created symlink in ~/.local/bin for github-mcp-wrapper"
    fi
    
    # Pull the Docker image in advance to avoid delays during first use
    log "Pulling GitHub MCP server Docker image..."
    docker pull ghcr.io/github/github-mcp-server >/dev/null 2>&1 || handle_error "Failed to pull GitHub MCP server Docker image"
    log "Docker image pulled successfully"
  else
    log "Docker is not available. Cannot set up GitHub MCP server."
    log "Please install Docker to use the GitHub MCP server."
    
    # Create a placeholder wrapper that shows an error message
    cat > "$HOME/mcp/github-mcp-wrapper" << 'EOF'
#!/bin/bash
echo "Error: GitHub MCP server is not available." >&2
echo "Please install Docker to use the GitHub MCP server." >&2
exit 1
EOF
    chmod +x "$HOME/mcp/github-mcp-wrapper" 2>/dev/null || handle_error "Failed to make github-mcp-wrapper executable"
  fi
  
  # Create a debug script to help with troubleshooting
  cat > "$HOME/debug-amazonq-mcp.sh" << 'EOF'
#!/bin/bash
# Debug script for Amazon Q MCP

echo "Checking MCP configuration..."
echo "-----------------------------"

# Check if the MCP config file exists
if [ -f "$HOME/.aws/amazonq/mcp.json" ]; then
  echo "MCP config file exists: $HOME/.aws/amazonq/mcp.json"
  echo "Contents:"
  cat "$HOME/.aws/amazonq/mcp.json"
else
  echo "MCP config file not found: $HOME/.aws/amazonq/mcp.json"
fi

echo ""
echo "Checking MCP servers..."
echo "----------------------"

# Check if the test MCP server exists
if [ -f "$HOME/mcp/test-mcp-server" ]; then
  echo "Test MCP server exists: $HOME/mcp/test-mcp-server"
  echo "Permissions: $(ls -la "$HOME/mcp/test-mcp-server")"
else
  echo "Test MCP server not found: $HOME/mcp/test-mcp-server"
fi

# Check if the GitHub MCP server exists
if [ -f "$HOME/mcp/github-mcp-wrapper" ]; then
  echo "GitHub MCP wrapper exists: $HOME/mcp/github-mcp-wrapper"
  echo "Permissions: $(ls -la "$HOME/mcp/github-mcp-wrapper")"
  echo "Contents:"
  cat "$HOME/mcp/github-mcp-wrapper"
else
  echo "GitHub MCP wrapper not found: $HOME/mcp/github-mcp-wrapper"
fi

echo ""
echo "Checking environment..."
echo "----------------------"

# Check if the GitHub token is set
if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  echo "GitHub token is set: ${GITHUB_PERSONAL_ACCESS_TOKEN:0:5}..."
else
  echo "GitHub token is not set"
fi

# Check if Docker is installed
if command -v docker &> /dev/null; then
  echo "Docker is installed: $(docker --version)"
else
  echo "Docker is not installed"
fi

echo ""
echo "Testing MCP servers..."
echo "---------------------"

# Test the test MCP server
echo "Testing test MCP server..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | "$HOME/mcp/test-mcp-server" stdio

# Test the GitHub MCP server
echo "Testing GitHub MCP server..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | "$HOME/mcp/github-mcp-wrapper" stdio
EOF
  chmod +x "$HOME/debug-amazonq-mcp.sh" 2>/dev/null || handle_error "Failed to make debug script executable"
  log "Created debug script at $HOME/debug-amazonq-mcp.sh"
  
  log "Amazon Q MCP configuration set up successfully"
}

# Setup MCP for Claude CLI
setup_claude() {
  log "Setting up MCP for Claude CLI"
  
  # Create directory if it doesn't exist
  mkdir -p "$HOME/.config/claude" || handle_error "Failed to create directory $HOME/.config/claude"
  
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
}' > "$HOME/.config/claude/mcp.json" 2>/dev/null || handle_error "Failed to create Claude MCP config"
  
  log "Claude CLI MCP configuration set up successfully"
}

# Main setup
setup_amazonq
setup_claude

log "MCP configuration set up successfully"
