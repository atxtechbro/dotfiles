#!/bin/bash

# =========================================================
# SLACK MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Slack MCP server
# This script is called by the MCP system during normal operation
# It loads credentials from ~/.bash_secrets and passes them to the server
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-slack-mcp.sh script is the one-time setup
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
if [ -z "$SLACK_BOT_TOKEN" ]; then
  echo "Error: Missing SLACK_BOT_TOKEN in ~/.bash_secrets" >&2
  echo "Please add the following variable to your ~/.bash_secrets file:" >&2
  echo "  export SLACK_BOT_TOKEN=\"your_bot_token\"" >&2
  exit 1
fi

# Run the Slack MCP server with credentials from environment variables
exec docker run -i --rm \
  -e SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN" \
  --network=host \
  mcp/slack
