#!/bin/bash

# =========================================================
# GITLAB MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the MCP GitLab server
# This script is called by the MCP system during normal operation
# 
# RELATIONSHIP: This wrapper enforces work machine restrictions
# and delegates to npx to run the GitLab MCP server
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if this is a work machine
if [[ "$WORK_MACHINE" != "true" ]]; then
    echo "GitLab MCP server only available on work machines" >&2
    echo "Set WORK_MACHINE=true in ~/.bash_exports.local to enable" >&2
    exit 1
fi

# Check if npx is available
mcp_check_command "GITLAB" "npx" "Install npm/npx: sudo apt-get install npm"

# Source secrets file
mcp_source_secrets "GITLAB"

# Check if required GitLab environment variables are set
mcp_check_env_var "GITLAB" "GITLAB_URL" "Add: export GITLAB_URL=\"https://gitlab.example.com\""
mcp_check_env_var "GITLAB" "GITLAB_PAT" "Add: export GITLAB_PAT=\"your_personal_access_token\""

# Pass through any environment variables from the MCP config
export GITLAB_READ_ONLY_MODE="${GITLAB_READ_ONLY_MODE:-false}"
export USE_GITLAB_WIKI="${USE_GITLAB_WIKI:-true}"
export USE_MILESTONE="${USE_MILESTONE:-true}"
export USE_PIPELINE="${USE_PIPELINE:-true}"

# Run the GitLab MCP server via npx
mcp_exec_with_logging "GITLAB" npx gitlab-mcp