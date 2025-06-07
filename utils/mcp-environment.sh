#!/bin/bash
# MCP Environment Configuration Utility
# Provides functions for environment-aware MCP server configuration
# Following the "Spilled Coffee Principle" - making setup reproducible across machines

# Default environment-specific server configurations
# Format: Array of server names to disable in specific environments
PERSONAL_DISABLED_SERVERS=("atlassian")
WORK_DISABLED_SERVERS=("gdrive")
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
  export -f detect_environment
fi
