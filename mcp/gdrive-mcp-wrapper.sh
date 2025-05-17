#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Google Drive MCP server
# This script is called by the MCP system during normal operation
# It loads credentials from ~/.bash_secrets and passes them to the server
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-gdrive-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Source secrets file if it exists
if [ -f ~/.bash_secrets ]; then
  source ~/.bash_secrets
else
  echo "Error: ~/.bash_secrets file not found. Please create it using the template." >&2
  exit 1
fi

# Check if required environment variables are set
if [ -z "$GOOGLE_DRIVE_CLIENT_ID" ] || [ -z "$GOOGLE_DRIVE_CLIENT_SECRET" ] || [ -z "$GOOGLE_DRIVE_REFRESH_TOKEN" ]; then
  echo "Error: Missing Google Drive credentials in ~/.bash_secrets" >&2
  echo "Please add the following variables to your ~/.bash_secrets file:" >&2
  echo "  export GOOGLE_DRIVE_CLIENT_ID=\"your_client_id\"" >&2
  echo "  export GOOGLE_DRIVE_CLIENT_SECRET=\"your_client_secret\"" >&2
  echo "  export GOOGLE_DRIVE_REFRESH_TOKEN=\"your_refresh_token\"" >&2
  exit 1
fi

# Run the Google Drive MCP server with credentials from environment variables
exec docker run -i --rm \
  -e GOOGLE_DRIVE_CLIENT_ID="$GOOGLE_DRIVE_CLIENT_ID" \
  -e GOOGLE_DRIVE_CLIENT_SECRET="$GOOGLE_DRIVE_CLIENT_SECRET" \
  -e GOOGLE_DRIVE_REFRESH_TOKEN="$GOOGLE_DRIVE_REFRESH_TOKEN" \
  --network=host \
  mcp/gdrive
