#!/bin/bash

# =========================================================
# GITLAB MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the MCP GitLab server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if this is a work machine - run stub server if not
if [[ "$WORK_MACHINE" != "true" ]]; then
  exec python3 "$SCRIPT_DIR/utils/disabled-server-stub.py"
fi

# Check if npx is available (required to run the GitLab MCP server)
mcp_check_command "GITLAB" "npx" "Install Node.js: brew install node"

# Source secrets file
mcp_source_secrets "GITLAB"

# Check if required GitLab environment variables are set
mcp_check_env_var "GITLAB" "GITLAB_TOKEN" "Add: export GITLAB_TOKEN=\"your_gitlab_personal_access_token\""
mcp_check_env_var "GITLAB" "GITLAB_URL" "Add: export GITLAB_URL=\"https://gitlab.com\" or your GitLab instance URL"

# Run the MCP GitLab server
mcp_exec_with_logging "GITLAB" npx -y @zereight/mcp-gitlab