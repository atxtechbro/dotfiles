#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Google Drive MCP server
# This script builds the Docker image and updates the secrets template
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The gdrive-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

# Source the utility functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils/mcp-setup-utils.sh"

echo "Setting up Google Drive MCP server..."

# Check prerequisites
check_docker_installed
check_dotfiles_repo
REPO_ROOT=$(get_repo_root)

# Setup MCP servers repository
setup_mcp_servers_repo

# Build Docker image
build_mcp_docker_image "gdrive"

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

# Print setup completion message
print_setup_complete \
  "Google Drive" \
  "   export GOOGLE_DRIVE_CLIENT_ID=\"your_client_id\"
   export GOOGLE_DRIVE_CLIENT_SECRET=\"your_client_secret\"
   export GOOGLE_DRIVE_REFRESH_TOKEN=\"your_refresh_token\"" \
  "- gdrive_list: List files and folders in Google Drive
- gdrive_get: Download a file from Google Drive
- gdrive_create: Create a new file in Google Drive
- gdrive_update: Update an existing file in Google Drive
- gdrive_delete: Delete a file or folder in Google Drive
- gdrive_search: Search for files in Google Drive"

echo -e "\nFor detailed instructions on setting up Google Drive OAuth authentication, see:"
echo -e "  \033[1mhttps://github.com/modelcontextprotocol/servers/tree/main/src/gdrive#authentication\033[0m\n"

