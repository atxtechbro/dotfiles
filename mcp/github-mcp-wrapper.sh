#!/bin/bash

# Get GitHub token from GitHub CLI
TOKEN=$(gh auth token)

# Check if token was retrieved successfully
if [ -z "$TOKEN" ]; then
  echo "Error: Failed to retrieve GitHub token. Make sure you're logged in with 'gh auth login'" >&2
  exit 1
fi

# Export the token as an environment variable
export GITHUB_PERSONAL_ACCESS_TOKEN="$TOKEN"

# Path to the GitHub MCP server binary
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
GITHUB_BINARY_PATH="$SCRIPT_DIR/servers/github"

# Check if the binary exists and is executable
if [ ! -x "$GITHUB_BINARY_PATH" ]; then
  echo "Error: GitHub MCP server binary not found or not executable at $GITHUB_BINARY_PATH" >&2
  echo "Please run setup-github-mcp.sh first to build the binary" >&2
  exit 1
fi

# Run the GitHub MCP server with the token
exec "$GITHUB_BINARY_PATH" stdio