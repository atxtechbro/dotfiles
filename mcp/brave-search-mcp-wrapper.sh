#!/bin/bash
# Brave Search MCP Server Wrapper
# Provides web search functionality via Brave Search API

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if npx is available
mcp_check_command "BRAVE_SEARCH" "npx" "Install Node.js and npm: brew install node"

# Source secrets and check environment
mcp_source_secrets "BRAVE_SEARCH"
mcp_check_env_var "BRAVE_SEARCH" "BRAVE_API_KEY" "Add to ~/.bash_secrets: export BRAVE_API_KEY=\"your_key\""

# Run the Brave Search MCP server via npx
mcp_exec_with_logging "BRAVE_SEARCH" npx -y @modelcontextprotocol/server-brave-search