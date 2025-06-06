#!/bin/bash

# Get GitLab token from GitLab CLI
if command -v glab &> /dev/null; then
  # Check if user is authenticated
  if ! glab auth status &> /dev/null; then
    echo "Error: Not authenticated with GitLab. Please run 'glab auth login' first." >&2
    exit 1
  fi
  
  # Get the token
  TOKEN=$(glab auth status -t 2>/dev/null | grep -oP 'Token: \K.*')
  
  # Check if token was retrieved successfully
  if [ -z "$TOKEN" ]; then
    echo "Error: Failed to retrieve GitLab token." >&2
    exit 1
  fi
  
  # Export the token as an environment variable
  export GITLAB_PERSONAL_ACCESS_TOKEN="$TOKEN"
else
  # Fall back to .bash_secrets if glab CLI is not available
  if [ -f "$HOME/.bash_secrets" ]; then
    source "$HOME/.bash_secrets"
  fi
  
  # Check if token is available
  if [ -z "$GITLAB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "Error: GITLAB_PERSONAL_ACCESS_TOKEN not found. Please authenticate with 'glab auth login' or set the token in ~/.bash_secrets" >&2
    exit 1
  fi
fi

# Set GitLab API URL if not already set
if [ -z "$GITLAB_API_URL" ]; then
  export GITLAB_API_URL="https://gitlab.com/api/v4"
fi

# Run the GitLab MCP server
exec npx -y @modelcontextprotocol/server-gitlab
