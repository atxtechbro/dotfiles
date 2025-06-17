#!/bin/bash

# =========================================================
# MCP LOGGING UTILITY FRAMEWORK
# =========================================================
# PURPOSE: Shared logging functions for MCP wrapper scripts
# This addresses the fundamental limitation where MCP clients
# suppress/hide server errors making debugging nearly impossible
# =========================================================

MCP_ERROR_LOG="$HOME/mcp-errors.log"

# Log an MCP error with consistent formatting
# Usage: mcp_log_error "SERVER_NAME" "Error message" "Optional remediation"
mcp_log_error() {
  local server_name="$1"
  local error_msg="$2"
  local remediation="${3:-}"
  
  local timestamp=$(date)
  local formatted_msg="$timestamp: [$server_name] MCP ERROR: $error_msg"
  
  # Write to error log
  echo "$formatted_msg" >> "$MCP_ERROR_LOG"
  
  # Write to stderr for any logging that might capture it
  echo "Error: $error_msg" >&2
  if [[ -n "$remediation" ]]; then
    echo "$remediation" >&2
  fi
  echo "Error logged to: $MCP_ERROR_LOG" >&2
  
  # Show desktop notification on macOS
  if command -v osascript &>/dev/null; then
    local notification_msg="[$server_name] MCP ERROR: $error_msg"
    osascript -e "display notification \"$notification_msg\" with title \"MCP Server Error\"" 2>/dev/null || true
  fi
}

# Check if secrets file exists and source it
# Usage: mcp_source_secrets "SERVER_NAME"
mcp_source_secrets() {
  local server_name="$1"
  
  if [[ -f ~/.bash_secrets ]]; then
    source ~/.bash_secrets
  else
    mcp_log_error "$server_name" "~/.bash_secrets file not found" "Please create it using the template"
    exit 1
  fi
}

# Check if required environment variable is set
# Usage: mcp_check_env_var "SERVER_NAME" "VAR_NAME" "Instructions for setting it"
mcp_check_env_var() {
  local server_name="$1"
  local var_name="$2"
  local instructions="$3"
  
  if [[ -z "${!var_name}" ]]; then
    mcp_log_error "$server_name" "Missing $var_name in ~/.bash_secrets" "$instructions"
    exit 1
  fi
}

# Check if Docker daemon is running
# Usage: mcp_check_docker "SERVER_NAME"
mcp_check_docker() {
  local server_name="$1"
  
  if ! docker info &>/dev/null; then
    mcp_log_error "$server_name" "Docker daemon not running" "Start with: open -a Docker"
    exit 1
  fi
}

# Check if command exists
# Usage: mcp_check_command "SERVER_NAME" "command_name" "Installation instructions"
mcp_check_command() {
  local server_name="$1"
  local command_name="$2"
  local instructions="$3"
  
  if ! command -v "$command_name" &>/dev/null; then
    mcp_log_error "$server_name" "$command_name not found" "$instructions"
    exit 1
  fi
}
