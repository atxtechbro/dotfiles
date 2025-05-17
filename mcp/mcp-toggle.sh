#!/bin/bash
# mcp-toggle.sh - Simple MCP Server Toggle System
# Enables/disables MCP servers based on a simple configuration file

set -e

# Determine dotfiles directory
if [ -z "$DOT_DEN" ]; then
  DOT_DEN="$HOME/ppv/pillars/dotfiles"
fi

# Configuration paths
CONFIG_FILE="$HOME/.mcp-enabled-servers"
TEMPLATE_FILE="$DOT_DEN/mcp/mcp-enabled-servers.template"
MCP_JSON="$DOT_DEN/mcp/mcp.json"
OUTPUT_JSON="$HOME/.aws/amazonq/mcp.json"
CLAUDE_JSON="$HOME/.config/Claude/claude_desktop_config.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create config file from template if it doesn't exist
init_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    cp "$TEMPLATE_FILE" "$CONFIG_FILE"
    echo -e "${GREEN}Created MCP server configuration at $CONFIG_FILE${NC}"
  else
    echo -e "${YELLOW}Configuration already exists at $CONFIG_FILE${NC}"
  fi
}

# List all available MCP servers from the master config
list_servers() {
  echo "Available MCP servers:"
  jq -r '.servers[].name' "$MCP_JSON" | sort
  
  echo -e "\nCurrently enabled servers:"
  grep -v "^#" "$CONFIG_FILE" | grep "=1" | cut -d= -f1 || echo "None"
  
  echo -e "\nCurrently disabled servers:"
  grep -v "^#" "$CONFIG_FILE" | grep "=0" | cut -d= -f1 || echo "None"
}

# Enable a specific server (set to 1)
enable_server() {
  local server=$1
  
  # Check if server exists in master config
  if ! jq -e ".servers[] | select(.name == \"$server\")" "$MCP_JSON" > /dev/null; then
    echo -e "${YELLOW}Server '$server' not found in MCP configuration${NC}"
    return 1
  fi
  
  # Check if already in config file
  if grep -q "^$server=" "$CONFIG_FILE"; then
    # Update value to 1
    sed -i "s/^$server=.*/$server=1/" "$CONFIG_FILE"
  else
    # Add it with value 1
    echo "$server=1" >> "$CONFIG_FILE"
  fi
  
  echo -e "${GREEN}Enabled MCP server: $server${NC}"
  echo "Run 'mcp-toggle.sh apply' to apply changes"
}

# Disable a specific server (set to 0)
disable_server() {
  local server=$1
  
  # Check if server exists in master config
  if ! jq -e ".servers[] | select(.name == \"$server\")" "$MCP_JSON" > /dev/null; then
    echo -e "${YELLOW}Server '$server' not found in MCP configuration${NC}"
    return 1
  fi
  
  # Check if already in config file
  if grep -q "^$server=" "$CONFIG_FILE"; then
    # Update value to 0
    sed -i "s/^$server=.*/$server=0/" "$CONFIG_FILE"
  else
    # Add it with value 0
    echo "$server=0" >> "$CONFIG_FILE"
  fi
  
  echo -e "${GREEN}Disabled MCP server: $server${NC}"
  echo "Run 'mcp-toggle.sh apply' to apply changes"
}

# Apply the configuration to generate mcp.json
apply_config() {
  # Get the base configuration
  local config=$(cat "$MCP_JSON")
  
  # Get all server names from the master config
  local all_servers=($(jq -r '.servers[].name' "$MCP_JSON"))
  
  # Create a new servers array with only enabled servers
  local new_config=$(echo "$config" | jq '.servers = []')
  
  # Process each server in the config file
  while IFS='=' read -r server value || [[ -n "$server" ]]; do
    # Skip comments and empty lines
    [[ "$server" =~ ^#.*$ || -z "$server" ]] && continue
    
    # Check if server exists in master config
    if jq -e ".servers[] | select(.name == \"$server\")" "$MCP_JSON" > /dev/null; then
      if [[ "$value" == "1" ]]; then
        # Add server to new config
        local server_config=$(jq -c ".servers[] | select(.name == \"$server\")" "$MCP_JSON")
        new_config=$(echo "$new_config" | jq ".servers += [$server_config]")
        echo "Enabling MCP server: $server"
      else
        echo "Disabling MCP server: $server"
      fi
    fi
  done < "$CONFIG_FILE"
  
  # Write the new configuration
  mkdir -p "$(dirname "$OUTPUT_JSON")"
  echo "$new_config" > "$OUTPUT_JSON"
  
  # Also update Claude Desktop config if it exists
  if [ -d "$(dirname "$CLAUDE_JSON")" ]; then
    mkdir -p "$(dirname "$CLAUDE_JSON")"
    echo "$new_config" > "$CLAUDE_JSON"
  fi
  
  # Count enabled servers
  local enabled_count=$(echo "$new_config" | jq '.servers | length')
  echo -e "${GREEN}MCP configuration updated with $enabled_count enabled servers${NC}"
}

# Set a server to on (1)
on_server() {
  enable_server "$1"
}

# Set a server to off (0)
off_server() {
  disable_server "$1"
}

# Show usage information
show_usage() {
  echo "MCP Toggle - Simple MCP Server Management"
  echo ""
  echo "Usage:"
  echo "  mcp-toggle.sh init      - Create initial configuration"
  echo "  mcp-toggle.sh list      - List available and enabled servers"
  echo "  mcp-toggle.sh on <server>     - Enable a server (set to 1)"
  echo "  mcp-toggle.sh off <server>    - Disable a server (set to 0)"
  echo "  mcp-toggle.sh apply     - Apply configuration changes"
  echo ""
  echo "Configuration file: $CONFIG_FILE"
  echo "Format: server=1 (enabled) or server=0 (disabled)"
}

# Main command router
case "$1" in
  init)
    init_config
    ;;
  list)
    list_servers
    ;;
  enable|on)
    if [ -z "$2" ]; then
      echo "Error: Please specify a server name"
      exit 1
    fi
    enable_server "$2"
    ;;
  disable|off)
    if [ -z "$2" ]; then
      echo "Error: Please specify a server name"
      exit 1
    fi
    disable_server "$2"
    ;;
  apply)
    apply_config
    ;;
  *)
    show_usage
    ;;
esac

exit 0