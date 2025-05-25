#!/bin/bash
# mcp-wrapper.sh - Environment-aware MCP configuration wrapper

# Path to the original MCP config
MCP_CONFIG="$HOME/.config/mcp/mcp.json"
MCP_CONFIG_TEMP="$HOME/.config/mcp/mcp.json.temp"

# Ensure MCP config directory exists
mkdir -p "$(dirname "$MCP_CONFIG")"

# Make a copy of the original config
cp "$MCP_CONFIG" "$MCP_CONFIG_TEMP" 2>/dev/null || echo "{}" > "$MCP_CONFIG_TEMP"

# Process environment variables to disable specific servers
if [[ "$MCP_DISABLE_ATLASSIAN" == "true" ]]; then
  jq 'del(.mcpServers.atlassian)' "$MCP_CONFIG_TEMP" > "$MCP_CONFIG_TEMP.new"
  mv "$MCP_CONFIG_TEMP.new" "$MCP_CONFIG_TEMP"
  echo "Disabled Atlassian MCP server for this environment" >&2
fi

if [[ "$MCP_DISABLE_SLACK" == "true" ]]; then
  jq 'del(.mcpServers.slack)' "$MCP_CONFIG_TEMP" > "$MCP_CONFIG_TEMP.new"
  mv "$MCP_CONFIG_TEMP.new" "$MCP_CONFIG_TEMP"
  echo "Disabled Slack MCP server for this environment" >&2
fi

# Add more servers as needed with the same pattern

# Use the modified config for the MCP client
# This assumes you're using this wrapper to launch Amazon Q or Claude
q chat --mcp-config "$MCP_CONFIG_TEMP" "$@"

# Clean up
rm "$MCP_CONFIG_TEMP"