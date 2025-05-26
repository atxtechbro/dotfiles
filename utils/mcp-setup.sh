#!/bin/bash
# ~/ppv/pillars/dotfiles/utils/mcp-setup.sh
# Script to set up MCP environment-specific configurations

MCP_DIR="${HOME}/ppv/pillars/dotfiles/mcp-configs"
MCP_SOURCE="${HOME}/ppv/pillars/dotfiles/mcp/mcp.json"

# Create mcp-configs directory if it doesn't exist
mkdir -p "$MCP_DIR"

# Create work and personal configs if they don't exist
if [ ! -f "${MCP_DIR}/mcp.work.json" ]; then
  echo "Creating work MCP configuration..."
  cp "$MCP_SOURCE" "${MCP_DIR}/mcp.work.json"
  echo "Work MCP configuration created at ${MCP_DIR}/mcp.work.json"
fi

if [ ! -f "${MCP_DIR}/mcp.personal.json" ]; then
  echo "Creating personal MCP configuration..."
  cp "$MCP_SOURCE" "${MCP_DIR}/mcp.personal.json"
  
  # Remove Atlassian from personal config
  if command -v jq &> /dev/null; then
    echo "Removing Atlassian server from personal configuration..."
    jq '.servers = [.servers[] | select(.name != "atlassian")]' \
      "${MCP_DIR}/mcp.personal.json" > "${MCP_DIR}/temp.json" && \
      mv "${MCP_DIR}/temp.json" "${MCP_DIR}/mcp.personal.json"
    echo "Atlassian server removed from personal configuration"
  else
    echo "jq not found. Please install jq to automatically remove Atlassian server."
    echo "You can manually edit ${MCP_DIR}/mcp.personal.json to remove the Atlassian server."
  fi
  
  echo "Personal MCP configuration created at ${MCP_DIR}/mcp.personal.json"
fi

# Make mcp-select.sh executable
chmod +x "${HOME}/ppv/pillars/dotfiles/utils/mcp-select.sh"

echo "MCP environment configurations set up successfully."
echo "Use 'mcp-work' or 'mcp-personal' to switch between configurations."