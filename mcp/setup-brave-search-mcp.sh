#!/bin/bash

# =========================================================
# BRAVE SEARCH MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Brave Search MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The brave-search-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

# Source the utility functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils/mcp-setup-utils.sh"

echo "Setting up Brave Search MCP server..."

# Check prerequisites
check_docker_installed
check_dotfiles_repo
REPO_ROOT=$(get_repo_root)

# Setup MCP servers repository
setup_mcp_servers_repo

# Build Docker image
build_mcp_docker_image "brave-search"

# Update secrets template
update_secrets_template \
  "$REPO_ROOT" \
  "BRAVE_SEARCH_API_KEY" \
  "BRAVE SEARCH API CREDENTIALS" \
  "Get API key from: https://brave.com/search/api/" \
  "export BRAVE_SEARCH_API_KEY=\"your_api_key\""

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

# Print setup completion message
print_setup_complete \
  "Brave Search" \
  "   export BRAVE_SEARCH_API_KEY=\"your_api_key\"" \
  "- brave_search: Search the web using Brave Search
- brave_suggest: Get search suggestions from Brave"
