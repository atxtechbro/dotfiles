#!/bin/bash

# Load environment variables from .bash_secrets
if [ -f "$HOME/.bash_secrets" ]; then
  source "$HOME/.bash_secrets"
fi

# Check if GitLab token is available
if [ -z "$GITLAB_PERSONAL_ACCESS_TOKEN" ]; then
  echo "Error: GITLAB_PERSONAL_ACCESS_TOKEN not found in ~/.bash_secrets" >&2
  echo "Please add your GitLab token to ~/.bash_secrets:" >&2
  echo "export GITLAB_PERSONAL_ACCESS_TOKEN=\"your_token_here\"" >&2
  exit 1
fi

# Run the GitLab MCP server
exec npx -y @modelcontextprotocol/server-gitlab
