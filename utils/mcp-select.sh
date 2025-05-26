#!/bin/bash
# ~/ppv/pillars/dotfiles/utils/mcp-select.sh
# Script to switch between different MCP configurations

ENV_TYPE="$1"
MCP_DIR="${HOME}/ppv/pillars/dotfiles/mcp-configs"
MCP_DEST="${HOME}/.mcp.json"

if [ "$ENV_TYPE" != "work" ] && [ "$ENV_TYPE" != "personal" ]; then
  echo "Usage: mcp-select.sh [work|personal]"
  echo "Current configuration:"
  if [ -f "$MCP_DEST" ]; then
    if [ -L "$MCP_DEST" ]; then
      echo "$(readlink -f "$MCP_DEST")"
    else
      echo "Custom configuration (not managed by mcp-select)"
    fi
  else
    echo "No configuration set"
  fi
  exit 1
fi

# Check if the target config exists
if [ ! -f "${MCP_DIR}/mcp.${ENV_TYPE}.json" ]; then
  echo "Error: ${MCP_DIR}/mcp.${ENV_TYPE}.json does not exist"
  echo "Please run setup.sh first to create the configuration files"
  exit 1
fi

# Create symlink to the selected config
ln -sf "${MCP_DIR}/mcp.${ENV_TYPE}.json" "$MCP_DEST"
echo "MCP configuration set to ${ENV_TYPE}"
echo "Restart Amazon Q CLI for changes to take effect"