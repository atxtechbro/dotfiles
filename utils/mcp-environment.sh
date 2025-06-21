#!/bin/bash
# MCP Environment Configuration Utility
# Provides functions for environment-aware MCP server configuration
# Following the "Spilled Coffee Principle" - making setup reproducible across machines

# Default environment-specific server configurations
# Format: Array of server names to disable in specific environments
PERSONAL_DISABLED_SERVERS=("atlassian" "gitlab")
WORK_DISABLED_SERVERS=()
DEVELOPMENT_DISABLED_SERVERS=()
PRODUCTION_DISABLED_SERVERS=("experimental" "beta")

# Function to filter MCP servers from a configuration file based on environment
# Usage: filter_mcp_config <config_file> <environment>
filter_mcp_config() {
  local config_file="$1"
  local environment="${2:-personal}"
  local disabled_servers=()
  
  # Select the appropriate server list based on environment
  case "$environment" in
    "work")
      # Work environment - disable servers not needed in work context
      disabled_servers=("${WORK_DISABLED_SERVERS[@]}")
      ;;
    "development")
      disabled_servers=("${DEVELOPMENT_DISABLED_SERVERS[@]}")
      ;;
    "production")
      disabled_servers=("${PRODUCTION_DISABLED_SERVERS[@]}")
      ;;
    *)
      # Default to personal environment
      disabled_servers=("${PERSONAL_DISABLED_SERVERS[@]}")
      ;;
  esac
  
  # If no servers to disable, exit early
  if [[ ${#disabled_servers[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Removing servers for $environment environment: ${disabled_servers[*]}"
  
  # Create a jq filter to remove the specified servers
  local jq_filter=""
  for server in "${disabled_servers[@]}"; do
    jq_filter+="del(.mcpServers.\"$server\") | "
  done
  jq_filter="${jq_filter%| }"
  
  # Apply the filter
  local temp_file="${config_file}.tmp"
  jq "$jq_filter" "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
}

# Function to set disabled flag for MCP servers based on environment
# Usage: set_disabled_servers <config_file> <environment>
set_disabled_servers() {
  local config_file="$1"
  local environment="${2:-personal}"
  local servers_to_disable=()
  
  # Select the appropriate server list based on environment
  case "$environment" in
    "work")
      servers_to_disable=("${WORK_DISABLED_SERVERS[@]}")
      ;;
    "development")
      servers_to_disable=("${DEVELOPMENT_DISABLED_SERVERS[@]}")
      ;;
    "production")
      servers_to_disable=("${PRODUCTION_DISABLED_SERVERS[@]}")
      ;;
    *)
      # Default to personal environment
      servers_to_disable=("${PERSONAL_DISABLED_SERVERS[@]}")
      ;;
  esac
  
  # If no servers to disable, exit early
  if [[ ${#servers_to_disable[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Setting disabled=true for servers in $environment environment: ${servers_to_disable[*]}"
  
  # Create a jq filter to set disabled=true for the specified servers
  local jq_filter=""
  for server in "${servers_to_disable[@]}"; do
    jq_filter+=".mcpServers.\"$server\".disabled = true | "
  done
  jq_filter="${jq_filter%| }"
  
  # Apply the filter
  local temp_file="${config_file}.tmp"
  jq "$jq_filter" "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
}

# Function to enable specific MCP servers by setting disabled=false
# Usage: enable_mcp_servers <config_file> <server1> [<server2> ...]
enable_mcp_servers() {
  local config_file="$1"
  shift
  local servers_to_enable=("$@")
  
  # If no servers to enable, exit early
  if [[ ${#servers_to_enable[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Enabling servers: ${servers_to_enable[*]}"
  
  # Create a jq filter to set disabled=false for the specified servers
  local jq_filter=""
  for server in "${servers_to_enable[@]}"; do
    jq_filter+=".mcpServers.\"$server\".disabled = false | "
  done
  jq_filter="${jq_filter%| }"
  
  # Apply the filter
  local temp_file="${config_file}.tmp"
  jq "$jq_filter" "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
}

# Function to disable specific MCP servers by setting disabled=true
# Usage: disable_mcp_servers <config_file> <server1> [<server2> ...]
disable_mcp_servers() {
  local config_file="$1"
  shift
  local servers_to_disable=("$@")
  
  # If no servers to disable, exit early
  if [[ ${#servers_to_disable[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Disabling servers: ${servers_to_disable[*]}"
  
  # Create a jq filter to set disabled=true for the specified servers
  local jq_filter=""
  for server in "${servers_to_disable[@]}"; do
    jq_filter+=".mcpServers.\"$server\".disabled = true | "
  done
  jq_filter="${jq_filter%| }"
  
  # Apply the filter
  local temp_file="${config_file}.tmp"
  jq "$jq_filter" "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
}

# Function to determine the current environment
# Returns: Environment name (work, personal, development, production)
detect_environment() {
  # Check for explicit environment variable
  if [[ -n "$WORK_MACHINE" ]]; then
    if [[ "$WORK_MACHINE" == "true" ]]; then
      echo "work"
      return 0
    else
      echo "personal"
      return 0
    fi
  fi
  
  # Check for environment indicator files
  if [[ -f "$HOME/.work-environment" ]]; then
    echo "work"
  elif [[ -f "$HOME/.development-environment" ]]; then
    echo "development"
  elif [[ -f "$HOME/.production-environment" ]]; then
    echo "production"
  else
    # Default to personal environment
    echo "personal"
  fi
}

# If script is sourced, export the functions
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  export -f filter_mcp_config
  export -f set_disabled_servers
  export -f enable_mcp_servers
  export -f disable_mcp_servers
  export -f detect_environment
fi
