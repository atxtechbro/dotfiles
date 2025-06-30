#!/bin/bash

# =========================================================
# ATLASSIAN MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the MCP Atlassian server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-atlassian-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if this is a work machine
if [[ "$WORK_MACHINE" != "true" ]]; then
    echo "Atlassian MCP server only available on work machines" >&2
    echo "Set WORK_MACHINE=true in ~/.bash_exports.local to enable" >&2
    exit 1
fi

# Check if uvx is available (required to run the mcp-atlassian Python package)
mcp_check_command "ATLASSIAN" "uvx" "Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"

# Source secrets file
mcp_source_secrets "ATLASSIAN"

# Check if required Confluence environment variables are set
mcp_check_env_var "ATLASSIAN" "ATLASSIAN_CONFLUENCE_URL" "Add: export ATLASSIAN_CONFLUENCE_URL=\"https://your-domain.atlassian.net/wiki\""
mcp_check_env_var "ATLASSIAN" "ATLASSIAN_CONFLUENCE_USERNAME" "Add: export ATLASSIAN_CONFLUENCE_USERNAME=\"your.email@domain.com\""
mcp_check_env_var "ATLASSIAN" "ATLASSIAN_CONFLUENCE_API_TOKEN" "Add: export ATLASSIAN_CONFLUENCE_API_TOKEN=\"your_api_token\""

# Check if required Jira environment variables are set
mcp_check_env_var "ATLASSIAN" "ATLASSIAN_JIRA_URL" "Add: export ATLASSIAN_JIRA_URL=\"https://your-domain.atlassian.net\""
mcp_check_env_var "ATLASSIAN" "ATLASSIAN_JIRA_USERNAME" "Add: export ATLASSIAN_JIRA_USERNAME=\"your.email@domain.com\""
mcp_check_env_var "ATLASSIAN" "ATLASSIAN_JIRA_API_TOKEN" "Add: export ATLASSIAN_JIRA_API_TOKEN=\"your_api_token\""

# Run the MCP Atlassian server with credentials from environment variables
mcp_exec_with_logging "ATLASSIAN" uvx mcp-atlassian \
  --confluence-url="$ATLASSIAN_CONFLUENCE_URL" \
  --confluence-username="$ATLASSIAN_CONFLUENCE_USERNAME" \
  --confluence-token="$ATLASSIAN_CONFLUENCE_API_TOKEN" \
  --jira-url="$ATLASSIAN_JIRA_URL" \
  --jira-username="$ATLASSIAN_JIRA_USERNAME" \
  --jira-token="$ATLASSIAN_JIRA_API_TOKEN"
