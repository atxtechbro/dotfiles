#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Google Drive MCP server
# This script is called by the MCP system during normal operation
# Enhanced with error logging to address MCP client logging limitations
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-gdrive-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source MCP logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

# Check if Docker daemon is running
mcp_check_docker "GDRIVE"

# Check if Docker image exists
if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "mcp/gdrive"; then
  mcp_log_error "GDRIVE" "Docker image mcp/gdrive not found" "Run setup-gdrive-mcp.sh to build the Docker image"
  exit 1
fi

# Check if Docker volume exists
if ! docker volume ls --format "table {{.Name}}" | grep -q "mcp-gdrive"; then
  mcp_log_error "GDRIVE" "Docker volume mcp-gdrive not found" "Run setup-gdrive-mcp.sh to create the volume and credentials"
  exit 1
fi

# Run the Google Drive MCP server using Docker
exec docker run -i --rm \
  -v mcp-gdrive:/gdrive-server \
  -e GDRIVE_CREDENTIALS_PATH=/gdrive-server/credentials.json \
  mcp/gdrive
