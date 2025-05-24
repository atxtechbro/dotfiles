#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Google Drive MCP server
# This script is called by the MCP system during normal operation
# It uses Docker to run the Google Drive MCP server with the credentials
# stored in the Docker volume
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-gdrive-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Run the Google Drive MCP server using Docker
exec docker run -i --rm \
  -v mcp-gdrive:/gdrive-server \
  -e GDRIVE_CREDENTIALS_PATH=/gdrive-server/credentials.json \
  mcp/gdrive
