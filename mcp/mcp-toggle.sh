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
  grep -v "^#" "$CONFIG_FILE" | grep -v "^$" || echo "None"
}

# Enable a specific server
enable_server() {
  local server=$1
  
  # Check if server exists in master config
  if ! jq -e ".servers[] | select(.name == \"$server\")" "$MCP_JSON" > /dev/null; then
    echo -e "${YELLOW}Server '$server' not found in MCP configuration${NC}"
    return 1
  fi
  
  # Check if already enabled (not commented out)
  if grep -q "^$server$" "$CONFIG_FILE"; then
    echo -e "${YELLOW}Server '$server' is already enabled${NC}"
    return 0
  fi
  
  # If commented out, uncomment it
  if grep -q "^#[[:space:]]*$server$" "$CONFIG_FILE"; then
    sed -i "s/^#[[:space:]]*$server$/$server/" "$CONFIG_FILE"
  else
    # Otherwise add it
    echo "$server" >> "$CONFIG_FILE"
  fi
  
  echo -e "${GREEN}Enabled MCP server: $server${NC}"
  echo "Run 'mcp-toggle.sh apply' to apply changes"
}

# Disable a specific server
disable_server() {
  local server=$1
  
  # Check if already disabled or not in file
  if ! grep -q "^$server$" "$CONFIG_FILE"; then
    echo -e "${YELLOW}Server '$server' is already disabled or not in config${NC}"
    return 0
  fi
  
  # Comment out the server
  sed -i "s/^$server$/#$server/" "$CONFIG_FILE"
  
  echo -e "${GREEN}Disabled MCP server: $server${NC}"
  echo "Run 'mcp-toggle.sh apply' to apply changes"
}

# Apply the configuration to generate mcp.json
apply_config() {
  # Get the base configuration
  local config=$(cat "$MCP_JSON")
  
  # Get all server names from the master config
  local all_servers=($(jq -r '.servers[].name' "$MCP_JSON"))
  
  # Get enabled servers from config file
  local enabled_servers=($(grep -v "^#" "$CONFIG_FILE" | grep -v "^$"))
  
  # Create a new servers array with only enabled servers
  local new_config=$(echo "$config" | jq '.servers = []')
  
  # Add each enabled server from the original config
  for server in "${enabled_servers[@]}"; do
    local server_config=$(jq -c ".servers[] | select(.name == \"$server\")" "$MCP_JSON")
    if [ -n "$server_config" ]; then
      new_config=$(echo "$new_config" | jq ".servers += [$server_config]")
    fi
  done
  
  # Write the new configuration
  mkdir -p "$(dirname "$OUTPUT_JSON")"
  echo "$new_config" > "$OUTPUT_JSON"
  
  # Also update Claude Desktop config if it exists
  if [ -d "$(dirname "$CLAUDE_JSON")" ]; then
    mkdir -p "$(dirname "$CLAUDE_JSON")"
    echo "$new_config" > "$CLAUDE_JSON"
  fi
  
  echo -e "${GREEN}MCP configuration updated with $(echo ${#enabled_servers[@]}) enabled servers${NC}"
  echo "Enabled servers: ${enabled_servers[*]}"
}

# Show usage information
show_usage() {
  echo "MCP Toggle - Simple MCP Server Management"
  echo ""
  echo "Usage:"
  echo "  mcp-toggle.sh init      - Create initial configuration"
  echo "  mcp-toggle.sh list      - List available and enabled servers"
  echo "  mcp-toggle.sh enable <server>  - Enable a specific server"
  echo "  mcp-toggle.sh disable <server> - Disable a specific server"
  echo "  mcp-toggle.sh apply     - Apply configuration changes"
  echo ""
  echo "Configuration file: $CONFIG_FILE"
}

# Main command router
case "$1" in
  init)
    init_config
    ;;
  list)
    list_servers
    ;;
  enable)
    if [ -z "$2" ]; then
      echo "Error: Please specify a server name"
      exit 1
    fi
    enable_server "$2"
    ;;
  disable)
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