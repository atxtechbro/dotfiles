#!/bin/bash
# configure-claude-desktop-mcp.sh - Configure Claude Desktop to use Clojure MCP server
# This script follows the "Spilled Coffee Principle" and "Versioning Mindset"

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"
CONFIG_DIR=""
MCP_CONFIG_FILE=""

# Detect operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "macOS detected"
  CONFIG_DIR="$HOME/Library/Application Support/Claude"
  MCP_CONFIG_FILE="$CONFIG_DIR/mcp.json"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
  echo "Windows detected"
  CONFIG_DIR="$APPDATA/Claude"
  MCP_CONFIG_FILE="$CONFIG_DIR/mcp.json"
else
  echo "Linux detected"
  CONFIG_DIR="$HOME/.config/Claude"
  MCP_CONFIG_FILE="$CONFIG_DIR/mcp.json"
fi

echo -e "${YELLOW}Configuring Claude Desktop to use Clojure MCP server...${NC}"

# Create configuration directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Create MCP configuration specifically for Clojure MCP server
cat > "$MCP_CONFIG_FILE" << EOF
{
  "servers": [
    {
      "name": "clojure-mcp",
      "url": "http://localhost:7777",
      "enabled": true
    }
  ]
}
EOF

echo -e "${GREEN}✓ MCP configuration created at $MCP_CONFIG_FILE${NC}"
echo -e "Claude Desktop will now use only the Clojure MCP server."
echo -e "\nMake sure the Clojure MCP server is running with:"
echo -e "${YELLOW}$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh start${NC}"