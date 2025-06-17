#!/bin/bash

# =========================================================
# GITHUB MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the GitHub MCP server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if GitHub CLI is available
mcp_check_command "GITHUB" "gh" "Install GitHub CLI: brew install gh"

# Get GitHub token from GitHub CLI
TOKEN=$(gh auth token 2>/dev/null)

# Check if token was retrieved successfully
if [[ -z "$TOKEN" ]]; then
  mcp_log_error "GITHUB" "Failed to retrieve GitHub token" "Make sure you're logged in with: gh auth login"
  exit 1
fi

# Export the token as an environment variable
export GITHUB_PERSONAL_ACCESS_TOKEN="$TOKEN"

# Path to the GitHub MCP server binary
GITHUB_BINARY_PATH="$SCRIPT_DIR/servers/github"

# Check if the binary exists and is executable
if [[ ! -x "$GITHUB_BINARY_PATH" ]]; then
  mcp_log_error "GITHUB" "GitHub MCP server binary not found or not executable at $GITHUB_BINARY_PATH" "Run setup-github-mcp.sh to build the binary"
  exit 1
fi

# Run the GitHub MCP server with the token
mcp_exec_with_logging "GITHUB" "$GITHUB_BINARY_PATH" stdio