#!/bin/bash

# =========================================================
# GITLAB MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the in-house GitLab MCP server
# This script is called by the MCP system during normal operation
# 
# RELATIONSHIP: This wrapper runs our custom glab-based MCP server
# instead of the npm package for better pipeline debugging
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITLAB_MCP_DIR="${SCRIPT_DIR}/servers/gitlab-mcp-server"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if this is a work machine
if [[ "$WORK_MACHINE" != "true" ]]; then
    echo "GitLab MCP server only available on work machines" >&2
    echo "Set WORK_MACHINE=true in ~/.bash_exports.local to enable" >&2
    exit 1
fi

# Check if the GitLab MCP server is installed
if [ ! -d "${GITLAB_MCP_DIR}/.venv" ]; then
    echo "Error: GitLab MCP server is not installed. Please run:"
    echo "  ${SCRIPT_DIR}/setup-gitlab-mcp.sh"
    exit 1
fi

# Check if glab is available
mcp_check_command "GITLAB" "glab" "Install glab: brew install glab"

# Source secrets file (optional for glab-based server)
mcp_source_secrets "GITLAB" || true

# Run the in-house GitLab MCP server
mcp_exec_with_logging "GITLAB" "${GITLAB_MCP_DIR}/.venv/bin/python" -m gitlab_mcp_server