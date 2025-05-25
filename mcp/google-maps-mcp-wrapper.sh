#!/bin/bash

# =========================================================
# GOOGLE MAPS MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Google Maps MCP server
# This script is called by the MCP system during normal operation
# It loads credentials from ~/.bash_secrets and passes them to the server
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-google-maps-mcp.sh script is the one-time setup
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
if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
  echo "Error: Missing GOOGLE_MAPS_API_KEY in ~/.bash_secrets" >&2
  echo "Please add the following variable to your ~/.bash_secrets file:" >&2
  echo "  export GOOGLE_MAPS_API_KEY=\"your_api_key\"" >&2
  exit 1
fi

# Run the Google Maps MCP server with credentials from environment variables
exec docker run -i --rm \
  -e GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY" \
  --network=host \
  mcp/google-maps
