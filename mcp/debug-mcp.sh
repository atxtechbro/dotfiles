#!/bin/bash
# Debug and troubleshooting script for MCP servers

# Create log directory
LOG_DIR="/tmp/mcp-logs"
mkdir -p "$LOG_DIR"

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Check MCP server executables
echo "=== MCP Server Executables ==="
if [ -x "$HOME/mcp/test-mcp-server" ]; then
  echo "✓ test-mcp-server is installed and executable"
else
  echo "✗ test-mcp-server is missing or not executable"
fi

if [ -x "$HOME/mcp/github-mcp-server" ]; then
  echo "✓ github-mcp-server is installed and executable"
else
  echo "✗ github-mcp-server is missing or not executable"
fi

# Check PATH configuration
echo -e "\n=== PATH Configuration ==="
if echo "$PATH" | grep -q "$HOME/mcp"; then
  echo "✓ $HOME/mcp is in PATH"
else
  echo "✗ $HOME/mcp is NOT in PATH"
  echo "  Current PATH: $PATH"
fi

# Check MCP configuration files
echo -e "\n=== MCP Configuration Files ==="
if [ -f "$HOME/.aws/amazonq/mcp.json" ]; then
  echo "✓ Amazon Q MCP configuration exists"
  echo "  Content:"
  cat "$HOME/.aws/amazonq/mcp.json"
else
  echo "✗ Amazon Q MCP configuration is missing"
fi

# Test MCP servers directly
echo -e "\n=== Testing MCP Servers ==="
echo "Testing test-mcp-server..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | "$HOME/mcp/test-mcp-server" | head -n 1
echo "Testing github-mcp-server..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | "$HOME/mcp/github-mcp-server" | head -n 1

# Check for log files
echo -e "\n=== MCP Log Files ==="
if [ -f "$LOG_DIR/github-mcp-server.log" ]; then
  echo "✓ GitHub MCP server log exists"
  echo "  Last 5 lines:"
  tail -n 5 "$LOG_DIR/github-mcp-server.log"
else
  echo "✗ GitHub MCP server log is missing"
fi

echo -e "\n=== Recommendations ==="
echo "1. Ensure MCP servers are in your PATH"
echo "2. Check that MCP configuration files are properly formatted"
echo "3. Verify that MCP servers have execute permissions"
echo "4. Try running Amazon Q with debug logging:"
echo "   Q_LOG_LEVEL=trace q chat"
echo "5. Check the logs in $LOG_DIR for more details"
