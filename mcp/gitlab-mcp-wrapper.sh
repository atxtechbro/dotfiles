#!/bin/bash

# =========================================================
# GITLAB MCP WRAPPER SCRIPT - EXTERNAL SERVER
# =========================================================
# PURPOSE: Runtime wrapper that executes the external GitLab MCP server
# This script is called by the MCP system during normal operation
# 
# RELATIONSHIP: This wrapper runs the @zereight/mcp-gitlab external server
# instead of our custom implementation for reduced maintenance overhead
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

# Check if the external GitLab MCP server is installed
if ! command -v mcp-gitlab >/dev/null 2>&1; then
    echo "Error: External GitLab MCP server is not installed. Please run:"
    echo "  npm install -g @zereight/mcp-gitlab"
    exit 1
fi

# Source secrets file for GitLab token
mcp_source_secrets "GITLAB"

# Validate required environment variables
if [[ -z "$GITLAB_PERSONAL_ACCESS_TOKEN" ]]; then
    echo "Error: GITLAB_PERSONAL_ACCESS_TOKEN not found in environment" >&2
    echo "Please add GITLAB_PERSONAL_ACCESS_TOKEN to ~/.bash_secrets" >&2
    exit 1
fi

# Run the external GitLab MCP server
mcp_exec_with_logging "GITLAB" mcp-gitlab