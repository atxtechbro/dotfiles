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
    
    # Create the MCP configuration file
    log "Creating MCP configuration file..."
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
    }
  }
}' > "$MCP_CONFIG_FILE" 2>/dev/null || handle_error "Failed to create MCP config"
    log_success "Created MCP configuration file at $MCP_CONFIG_FILE"
  else
    log_error "Docker is not available. Cannot set up GitHub MCP server."
    log_warning "Please install Docker to use the GitHub MCP server."
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
echo "Testing GitHub MCP server..."
echo "--------------------------"

# Test the GitHub MCP server
echo "Testing GitHub MCP server with Docker..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | sudo docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" ghcr.io/github/github-mcp-server stdio
EOF
  chmod +x "$HOME/debug-amazonq-mcp.sh" 2>/dev/null || handle_error "Failed to make debug script executable"
  log_success "Created debug script at $HOME/debug-amazonq-mcp.sh"
  
  log_success "MCP configuration set up successfully"
}

# Function to verify MCP server initialization
verify_mcp_initialization() {
  log "Verifying MCP server initialization..."
  
  # Run Amazon Q with the test command and a timeout
  log "Running Amazon Q CLI test with 18s timeout..."
  local test_output
  test_output=$(timeout 18s bash -c "Q_LOG_LEVEL=trace q chat --no-interactive --trust-all-tools \"try to use the github___search_repositories tool to search for 'amazon-q', this is a test\"" 2>&1)
  local timeout_status=$?
  
  # Check if command timed out
  if [ $timeout_status -eq 124 ]; then
    log_error "Verification timed out after 18 seconds"
    log_error "Last output: $(echo "$test_output" | tail -5)"
    return 1
  fi
  
  # Display the output for debugging
  log "Test output preview:"
  echo "$test_output" | head -10
  
  # First check for explicit failure patterns
  if echo "$test_output" | grep -q "0 of"; then
    log_error "MCP server initialization failed! Output contains '0 of' indicating no servers initialized"
    log_error "Test output: $(echo "$test_output" | grep -E '(0 of|mcp servers initialized)' | head -3)"
    return 1
  fi
  
  # Then check for successful initialization patterns
  # We need to see a pattern like "N of N mcp servers initialized" where N > 0
  if echo "$test_output" | grep -E '[1-9][0-9]* of [1-9][0-9]* mcp servers initialized' -q; then
    log_success "MCP server initialization successful! Servers were properly initialized"
    log_success "Test output: $(echo "$test_output" | grep -E '([1-9][0-9]* of [1-9][0-9]* mcp servers initialized)' | head -1)"
    return 0
  else
    log_error "MCP server initialization failed! Could not confirm successful initialization"
    log_error "Test output snippet: $(echo "$test_output" | grep -E '(mcp servers initialized|failed|error)' | head -3 || echo "$test_output" | head -3)"
    return 1
  fi
}

# Main setup
setup_mcp

# Always verify MCP initialization (mandatory)
log "Running MCP verification test (this may take a few moments)..."
if verify_mcp_initialization; then
  log_success "MCP verification passed! Setup complete."
else
  log_error "MCP verification failed! Please check the logs and debug script."
  # Exit with error code to indicate failure
  return 1 2>/dev/null || exit 1
fi
