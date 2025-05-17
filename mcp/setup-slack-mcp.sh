#!/bin/bash

# =========================================================
# SLACK MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Slack MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The slack-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

# Source the utility functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils/mcp-setup-utils.sh"

echo "Setting up Slack MCP server..."

# Check prerequisites
check_docker_installed
check_dotfiles_repo
REPO_ROOT=$(get_repo_root)

# Setup MCP servers repository
setup_mcp_servers_repo

# Build Docker image
build_mcp_docker_image "slack"

# Update secrets template
update_secrets_template \
  "$REPO_ROOT" \
  "SLACK_BOT_TOKEN" \
  "SLACK API CREDENTIALS" \
  "Create a Slack app and get a bot token: https://api.slack.com/apps" \
  "export SLACK_BOT_TOKEN=\"xoxb-your-token\""

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

# Print setup completion message
print_setup_complete \
  "Slack" \
  "   export SLACK_BOT_TOKEN=\"xoxb-your-token\"" \
  "- slack_send_message: Send a message to a Slack channel or user
- slack_get_messages: Get messages from a Slack channel
- slack_list_channels: List available Slack channels
- slack_list_users: List users in your Slack workspace
- slack_search: Search for messages in Slack"
