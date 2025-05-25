#!/bin/bash

# =========================================================
# ATLASSIAN MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the MCP Atlassian server
# This script is called by the MCP system during normal operation
# It loads credentials from ~/.bash_secrets and passes them to the server
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-atlassian-mcp.sh script is the one-time setup
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
if [ -z "$ATLASSIAN_CONFLUENCE_URL" ] || [ -z "$ATLASSIAN_CONFLUENCE_USERNAME" ] || [ -z "$ATLASSIAN_CONFLUENCE_API_TOKEN" ] || \
   [ -z "$ATLASSIAN_JIRA_URL" ] || [ -z "$ATLASSIAN_JIRA_USERNAME" ] || [ -z "$ATLASSIAN_JIRA_API_TOKEN" ]; then
  echo "Error: Missing required Atlassian credentials in ~/.bash_secrets" >&2
  echo "Please add the following variables to your ~/.bash_secrets file:" >&2
  echo "  export ATLASSIAN_CONFLUENCE_URL=\"https://your-domain.atlassian.net/wiki\"" >&2
  echo "  export ATLASSIAN_CONFLUENCE_USERNAME=\"your.email@domain.com\"" >&2
  echo "  export ATLASSIAN_CONFLUENCE_API_TOKEN=\"your_api_token\"" >&2
  echo "  export ATLASSIAN_JIRA_URL=\"https://your-domain.atlassian.net\"" >&2
  echo "  export ATLASSIAN_JIRA_USERNAME=\"your.email@domain.com\"" >&2
  echo "  export ATLASSIAN_JIRA_API_TOKEN=\"your_api_token\"" >&2
  exit 1
fi

# Run the MCP Atlassian server with credentials from environment variables
exec uvx mcp-atlassian \
  --confluence-url="$ATLASSIAN_CONFLUENCE_URL" \
  --confluence-username="$ATLASSIAN_CONFLUENCE_USERNAME" \
  --confluence-token="$ATLASSIAN_CONFLUENCE_API_TOKEN" \
  --jira-url="$ATLASSIAN_JIRA_URL" \
  --jira-username="$ATLASSIAN_JIRA_USERNAME" \
  --jira-token="$ATLASSIAN_JIRA_API_TOKEN"
