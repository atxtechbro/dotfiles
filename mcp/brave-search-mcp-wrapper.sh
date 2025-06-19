#!/bin/bash

# =========================================================
# BRAVE SEARCH MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Brave Search MCP server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# 
# IMPORTANT: This MCP server uses Docker and will fail if Docker daemon
# is not running. Ensure Docker Desktop is started before using Amazon Q
# with MCP servers enabled.
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-brave-search-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Source secrets file
mcp_source_secrets "BRAVE"

# Check if required environment variables are set
mcp_check_env_var "BRAVE" "BRAVE_API_KEY" "Add: export BRAVE_API_KEY=\"your_api_key\""

# Ensure Docker is running
ensure-docker "Brave Search MCP"

# Run the Brave Search MCP server with credentials from environment variables
mcp_exec_with_logging "BRAVE" docker run -i --rm \
  -e BRAVE_API_KEY="$BRAVE_API_KEY" \
  --network=host \
  mcp/brave-search
