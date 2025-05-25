#!/bin/bash
# mcp-wrapper.sh - Environment-aware MCP configuration wrapper
# Part of the dotfiles "spilled coffee" principle implementation

# Ensure the script is executable
if [[ ! -x "$0" ]]; then
  chmod +x "$0"
fi

# Path to the original MCP config - UPDATED to use the correct path
MCP_CONFIG="$HOME/.aws/amazonq/mcp.json"
MCP_CONFIG_TEMP="$HOME/.aws/amazonq/mcp.json.temp"

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$MCP_CONFIG")" 2>/dev/null

# If the config doesn't exist, create a minimal one
if [[ ! -f "$MCP_CONFIG" ]]; then
  echo '{"mcpServers":{}}' > "$MCP_CONFIG"
  echo "Created default MCP configuration" >&2
fi

# Make a copy of the original config
cp "$MCP_CONFIG" "$MCP_CONFIG_TEMP"

# Process environment variables to disable specific servers
if [[ "$MCP_DISABLE_ATLASSIAN" == "true" ]]; then
  if command -v jq &>/dev/null; then
    jq 'del(.mcpServers.atlassian)' "$MCP_CONFIG_TEMP" > "$MCP_CONFIG_TEMP.new" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      mv "$MCP_CONFIG_TEMP.new" "$MCP_CONFIG_TEMP"
      echo "Disabled Atlassian MCP server for this environment" >&2
    else
      echo "Warning: Failed to disable Atlassian MCP server (jq error)" >&2
    fi
  else
    echo "Warning: jq not installed, cannot modify MCP configuration" >&2
  fi
fi

if [[ "$MCP_DISABLE_SLACK" == "true" ]]; then
  if command -v jq &>/dev/null; then
    jq 'del(.mcpServers.slack)' "$MCP_CONFIG_TEMP" > "$MCP_CONFIG_TEMP.new" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      mv "$MCP_CONFIG_TEMP.new" "$MCP_CONFIG_TEMP"
      echo "Disabled Slack MCP server for this environment" >&2
    else
      echo "Warning: Failed to disable Slack MCP server (jq error)" >&2
    fi
  else
    echo "Warning: jq not installed, cannot modify MCP configuration" >&2
  fi
fi

# Add more servers as needed with the same pattern

# Use the modified config for the MCP client
if command -v q &>/dev/null; then
  # Check if the first argument is 'chat' or not
  if [[ "$1" == "chat" ]]; then
    q chat --mcp-config "$MCP_CONFIG_TEMP" "${@:2}"
  else
    q --mcp-config "$MCP_CONFIG_TEMP" "$@"
  fi
  EXIT_CODE=$?
else
  echo "Error: Amazon Q CLI not found" >&2
  EXIT_CODE=1
fi

# Clean up
rm -f "$MCP_CONFIG_TEMP" "$MCP_CONFIG_TEMP.new" 2>/dev/null

exit $EXIT_CODE
