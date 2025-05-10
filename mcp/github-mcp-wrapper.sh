#!/bin/bash

# Get GitHub token from GitHub CLI
TOKEN=$(gh auth token)

# Check if token was retrieved successfully
if [ -z "$TOKEN" ]; then
  echo "Error: Failed to retrieve GitHub token. Make sure you're logged in with 'gh auth login'" >&2
  exit 1
fi

# Export the token as an environment variable
export GITHUB_TOKEN="$TOKEN"

# Run the GitHub MCP server with the token
exec docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" \
  --network=host \
  ghcr.io/github/github-mcp-server
