#!/bin/bash

# =========================================================
# GITHUB MCP WRITE WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the GitHub MCP server with write-only access
# This script is called by the MCP system during normal operation
# Uses the --write-only flag to restrict to write operations only
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Path to the GitHub MCP server binary
SERVER_BIN="$SCRIPT_DIR/servers/github"

# Check if server binary exists
if [[ ! -f "$SERVER_BIN" ]]; then
  mcp_log_error "GITHUB-WRITE" "Server binary not found: $SERVER_BIN" "Run setup-github-mcp.sh to install the GitHub MCP server"
  exit 1
fi

# Check if git command is available (needed for GitHub operations)
mcp_check_command "GITHUB-WRITE" "git" "Install Git: brew install git"

# Check if GitHub token is set
if [[ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]] && [[ -z "$GITHUB_TOKEN" ]]; then
  # Try to get token from gh CLI
  if command -v gh &> /dev/null; then
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
    if [[ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]]; then
      mcp_log_error "GITHUB-WRITE" "GitHub token not found" "Set GITHUB_TOKEN or authenticate with: gh auth login"
      exit 1
    fi
  else
    mcp_log_error "GITHUB-WRITE" "GitHub token not found" "Set GITHUB_TOKEN or install GitHub CLI and authenticate"
    exit 1
  fi
elif [[ -n "$GITHUB_TOKEN" ]] && [[ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]]; then
  # If GITHUB_TOKEN is set but not GITHUB_PERSONAL_ACCESS_TOKEN, copy it
  export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"
fi

# Run the server with write-only flag (only write operations)
mcp_exec_with_logging "GITHUB-WRITE" "$SERVER_BIN" stdio --write-only "$@"