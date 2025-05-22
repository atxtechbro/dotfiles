#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Google Drive MCP server
# This script is called by the MCP system during normal operation
# It mounts credentials from ~/tmp/gdrive-oath/credentials.json
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-gdrive-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Check if credentials file exists
CREDENTIALS_PATH=~/tmp/gdrive-oath/credentials.json
if [ ! -f "$CREDENTIALS_PATH" ]; then
  echo "Error: Google Drive credentials file not found at $CREDENTIALS_PATH" >&2
  echo "Please ensure the credentials.json file exists at this location" >&2
  exit 1
fi

# Create directory for mounting if it doesn't exist
mkdir -p $(dirname "$CREDENTIALS_PATH")

# Run the Google Drive MCP server with mounted credentials
exec docker run -i --rm \
  -v mcp-gdrive:/gdrive-server \
  -v "$CREDENTIALS_PATH":/gdrive-server/credentials.json \
  -e GDRIVE_CREDENTIALS_PATH=/gdrive-server/credentials.json \
  mcp/gdrive