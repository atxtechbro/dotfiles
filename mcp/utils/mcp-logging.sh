#!/bin/bash

# =========================================================
# MCP LOGGING UTILITY FRAMEWORK
# =========================================================
# PURPOSE: Shared logging functions for MCP wrapper scripts
# This addresses the fundamental limitation where MCP clients
# suppress/hide server errors making debugging nearly impossible
# =========================================================

MCP_ERROR_LOG="$HOME/mcp-errors.log"
MCP_TOOL_LOG="$HOME/mcp-tool-calls.log"

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

# Log an MCP tool call with detailed context
# Usage: mcp_log_tool_call "SERVER_NAME" "TOOL_NAME" "STATUS" "DETAILS" "REPO_PATH"
mcp_log_tool_call() {
  local server_name="$1"
  local tool_name="$2"
  local status="$3"  # SUCCESS or ERROR
  local details="$4"
  local repo_path="${5:-}"
  
  local timestamp=$(date)
  local branch="unknown"
  
  # Try to get current git branch if repo_path is provided
  if [[ -n "$repo_path" && -d "$repo_path/.git" ]]; then
    branch=$(cd "$repo_path" && git branch --show-current 2>/dev/null || echo "unknown")
  fi
  
  local formatted_msg="$timestamp: [$server_name] TOOL_CALL: $tool_name | STATUS: $status | BRANCH: $branch | DETAILS: $details"
  
  # Write to tool log
  echo "$formatted_msg" >> "$MCP_TOOL_LOG"
  
  # If it's an error, also log to error log
  if [[ "$status" == "ERROR" ]]; then
    echo "$timestamp: [$server_name] TOOL ERROR: $tool_name failed - $details" >> "$MCP_ERROR_LOG"
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

# Execute MCP server with runtime error capture
# Usage: mcp_exec_with_logging "SERVER_NAME" command [args...]
# This replaces the 'exec' pattern to capture runtime failures
mcp_exec_with_logging() {
  local server_name="$1"
  shift  # Remove server_name from arguments
  
  # Create temporary file for stderr capture
  local error_file=$(mktemp)
  
  # Execute the command, capturing stderr while preserving stdout for MCP protocol
  "$@" 2>"$error_file"
  local exit_code=$?
  
  # If command failed, log the error
  if [[ $exit_code -ne 0 ]]; then
    local error_output=""
    if [[ -s "$error_file" ]]; then
      # Read first few lines of error output for logging
      error_output=$(head -10 "$error_file" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')
    fi
    
    if [[ -n "$error_output" ]]; then
      mcp_log_error "$server_name" "Server process failed (exit $exit_code): $error_output" "Check server configuration and dependencies"
    else
      mcp_log_error "$server_name" "Server process failed with exit code $exit_code" "Check server configuration and dependencies"
    fi
  fi
  
  # Clean up temporary file
  rm -f "$error_file"
  
  # Exit with the same code as the server process
  exit $exit_code
}
