#!/bin/bash

# =========================================================
# TEST DISABLED FIELD SUPPORT
# =========================================================
# PURPOSE: Test that the disabled field is properly supported
# by the Amazon Q MCP client
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source MCP environment utilities
source "$DOTFILES_DIR/utils/mcp-environment.sh"

# Default MCP config file location
MCP_CONFIG_FILE="$DOTFILES_DIR/mcp/mcp.json"
TEST_CONFIG_FILE="/tmp/mcp-test-config.json"

# Create a backup of the original config
cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.bak"

# Create a test configuration with disabled servers
cat > "$TEST_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "test-enabled": {
      "command": "echo",
      "args": ["Enabled server"],
      "env": {}
    },
    "test-disabled": {
      "command": "echo",
      "args": ["Disabled server"],
      "env": {},
      "disabled": true
    },
    "test-explicit-enabled": {
      "command": "echo",
      "args": ["Explicitly enabled server"],
      "env": {},
      "disabled": false
    }
  }
}
EOF

# Function to run tests
run_tests() {
  echo "=== Testing disabled field support ==="
  echo ""
  
  echo "Test 1: List servers with disabled status"
  echo "-----------------------------------------"
  "$DOTFILES_DIR/bin/mcp-enable" --list
  echo ""
  
  echo "Test 2: Enable a disabled server"
  echo "-------------------------------"
  "$DOTFILES_DIR/bin/mcp-enable" test-disabled
  "$DOTFILES_DIR/bin/mcp-enable" --list | grep test-disabled
  echo ""
  
  echo "Test 3: Disable an enabled server"
  echo "--------------------------------"
  "$DOTFILES_DIR/bin/mcp-disable" test-enabled
  "$DOTFILES_DIR/bin/mcp-enable" --list | grep test-enabled
  echo ""
  
  echo "Test 4: Set disabled servers based on environment"
  echo "-----------------------------------------------"
  set_disabled_servers "$TEST_CONFIG_FILE" "personal"
  echo "After setting disabled servers for personal environment:"
  "$DOTFILES_DIR/bin/mcp-enable" --list
  echo ""
  
  echo "=== Tests completed ==="
}

# Clean up function
cleanup() {
  echo "Cleaning up..."
  if [[ -f "$MCP_CONFIG_FILE.bak" ]]; then
    mv "$MCP_CONFIG_FILE.bak" "$MCP_CONFIG_FILE"
    echo "Original configuration restored"
  fi
  rm -f "$TEST_CONFIG_FILE"
}

# Set up trap to ensure cleanup on exit
trap cleanup EXIT

# Run the tests
run_tests

echo ""
echo "To test with Amazon Q:"
echo "1. Copy the test configuration: cp $TEST_CONFIG_FILE ~/.amazon-q/mcp.json"
echo "2. Start Amazon Q: q chat"
echo "3. Verify that disabled servers are not loaded"
echo "4. Enable a server: mcp-enable test-disabled"
echo "5. Restart Amazon Q and verify the server is now loaded"
echo ""