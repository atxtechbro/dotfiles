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

# Update secrets template
update_secrets_template \
  "$REPO_ROOT" \
  "GOOGLE_DRIVE_CLIENT_ID" \
  "GOOGLE DRIVE API CREDENTIALS" \
  "Create credentials at: https://console.cloud.google.com/apis/credentials" \
  "export GOOGLE_DRIVE_CLIENT_ID=\"your_client_id\""

# Add additional environment variables to secrets template
SECRETS_EXAMPLE="$REPO_ROOT/.bash_secrets.example"
if grep -q "GOOGLE_DRIVE_CLIENT_ID" "$SECRETS_EXAMPLE" && ! grep -q "GOOGLE_DRIVE_CLIENT_SECRET" "$SECRETS_EXAMPLE"; then
  echo "# export GOOGLE_DRIVE_CLIENT_SECRET=\"your_client_secret\"" >> "$SECRETS_EXAMPLE"
  echo "# export GOOGLE_DRIVE_REFRESH_TOKEN=\"your_refresh_token\"" >> "$SECRETS_EXAMPLE"
fi

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
