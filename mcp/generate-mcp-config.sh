#!/bin/bash

# =========================================================
# MCP CONFIG GENERATOR
# =========================================================
# PURPOSE: Generate mcp.json based on WORK_MACHINE variable
# This allows work-only servers to be completely hidden on personal machines
# =========================================================

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define work-only server configurations
WORK_ONLY_SERVERS='"atlassian": {
      "command": "atlassian-mcp-wrapper.sh",
      "args": [],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    },
    "gitlab": {
      "command": "gitlab-mcp-wrapper.sh",
      "args": [],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "GITLAB_READ_ONLY_MODE": "false",
        "USE_GITLAB_WIKI": "true",
        "USE_MILESTONE": "true",
        "USE_PIPELINE": "true"
      }
    },'

# Check if we're on a work machine
if [[ "${WORK_MACHINE:-false}" == "true" ]]; then
    echo "🏢 Generating mcp.json for WORK machine..."
    # Include work-only servers
    sed -e "s|WORK_ONLY_SERVERS|${WORK_ONLY_SERVERS}|g" \
        -e "s|WORK_ONLY_TRAILING_COMMA|,|g" \
        "$SCRIPT_DIR/mcp.json.template" > "$SCRIPT_DIR/mcp.json"
else
    echo "🏠 Generating mcp.json for PERSONAL machine..."
    # Exclude work-only servers
    sed -e "s|WORK_ONLY_SERVERS||g" \
        -e "s|WORK_ONLY_TRAILING_COMMA||g" \
        "$SCRIPT_DIR/mcp.json.template" > "$SCRIPT_DIR/mcp.json"
fi

echo "✅ Generated mcp.json based on WORK_MACHINE=${WORK_MACHINE:-false}"

# Copy to Claude Code config directory if it exists
CLAUDE_CONFIG_DIR="$HOME/.config/claude-cli-nodejs"
if [[ -d "$CLAUDE_CONFIG_DIR" ]]; then
    echo "📋 Copying to Claude Code config directory..."
    cp "$SCRIPT_DIR/mcp.json" "$CLAUDE_CONFIG_DIR/mcp.json"
    echo "✅ Copied to $CLAUDE_CONFIG_DIR/mcp.json"
fi

echo ""
echo "🔄 To apply changes:"
echo "   1. Exit any running Claude Code sessions"
echo "   2. Start a new Claude Code session"
if [[ "${WORK_MACHINE:-false}" == "true" ]]; then
    echo "   3. Work-only servers (atlassian, gitlab) will be visible"
else
    echo "   3. Work-only servers (atlassian, gitlab) will be hidden"
fi