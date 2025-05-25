#!/bin/bash
# MCP Server Environment Controls
# Automatically loaded by .bashrc during setup

# Detect environment based on hostname
# This is a simple heuristic - adjust as needed for your specific environment
if [[ "$(hostname)" != *"work"* ]] && [[ "$(hostname)" != *"corp"* ]]; then
  # On personal computer, disable work-specific MCP servers
  export MCP_DISABLE_ATLASSIAN=true
  export MCP_DISABLE_SLACK=true
  # Add other servers to disable as needed
else
  # On work computer, enable all MCP servers by default
  export MCP_DISABLE_ATLASSIAN=false
  export MCP_DISABLE_SLACK=false
fi

# Check for environment override file
if [[ -f "$HOME/.mcp-environment" ]]; then
  source "$HOME/.mcp-environment"
fi

# Create the q alias that uses our wrapper
# This will override any existing q alias
alias q="$DOT_DEN/bin/mcp-wrapper.sh"

# Add a helper function to toggle MCP servers
mcp-toggle() {
  local server="$1"
  local state="$2"
  
  if [[ -z "$server" || -z "$state" ]]; then
    echo "Usage: mcp-toggle <server> <on|off>"
    echo "Example: mcp-toggle atlassian off"
    echo "Available servers: atlassian, slack"
    return 1
  fi
  
  # Convert to uppercase for environment variable
  local server_upper=$(echo "$server" | tr '[:lower:]' '[:upper:]')
  
  if [[ "$state" == "on" ]]; then
    export "MCP_DISABLE_${server_upper}=false"
    echo "Enabled $server MCP server"
  elif [[ "$state" == "off" ]]; then
    export "MCP_DISABLE_${server_upper}=true"
    echo "Disabled $server MCP server"
  else
    echo "Invalid state: $state (use 'on' or 'off')"
    return 1
  fi
  
  # Save to environment override file
  echo "export MCP_DISABLE_${server_upper}=${state}" >> "$HOME/.mcp-environment"
  echo "Setting saved to ~/.mcp-environment"
}

# Add a helper function to show current MCP server status
mcp-status() {
  echo "MCP Server Status:"
  echo "  Atlassian: $(if [[ "$MCP_DISABLE_ATLASSIAN" == "true" ]]; then echo "Disabled"; else echo "Enabled"; fi)"
  echo "  Slack: $(if [[ "$MCP_DISABLE_SLACK" == "true" ]]; then echo "Disabled"; else echo "Enabled"; fi)"
  # Add more servers as needed
}
