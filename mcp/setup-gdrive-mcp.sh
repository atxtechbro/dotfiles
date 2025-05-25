#!/bin/bash

# =========================================================
# GOOGLE DRIVE MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Google Drive MCP server
# This script sets up the Google Drive MCP server using Docker
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
check_dotfiles_repo
check_docker_installed
REPO_ROOT=$(get_repo_root)

# Create directories for credentials
CREDENTIALS_DIR=~/tmp/gdrive-oath
mkdir -p "$CREDENTIALS_DIR"

# Setup MCP servers repository for Docker image
setup_mcp_servers_repo

# Build Docker image for Google Drive MCP server
echo "Building Docker image for Google Drive MCP server..."
build_mcp_docker_image "gdrive"

# Check if credentials.json exists
if [ -f "$CREDENTIALS_DIR/credentials.json" ]; then
  echo "Found existing credentials.json at $CREDENTIALS_DIR/credentials.json"
  
  # Run Docker authentication using existing credentials
  echo -e "\n\033[1mRunning authentication with Docker...\033[0m"
  docker run -i --rm --mount type=bind,source="$CREDENTIALS_DIR/credentials.json",target=/gcp-oauth.keys.json \
    -v mcp-gdrive:/gdrive-server \
    -e GDRIVE_OAUTH_PATH=/gcp-oauth.keys.json \
    -e "GDRIVE_CREDENTIALS_PATH=/gdrive-server/credentials.json" \
    --network host \
    mcp/gdrive auth
    
  # Verify the credentials file was created in the Docker volume
  CREDS_CHECK=$(docker run --rm -v mcp-gdrive:/gdrive-server busybox cat /gdrive-server/credentials.json 2>/dev/null)
  if [ -n "$CREDS_CHECK" ]; then
    echo -e "\n\033[32mAuthentication successful!\033[0m"
    echo "Credentials saved to Docker volume mcp-gdrive"
  else
    echo -e "\n\033[31mAuthentication failed. Credentials file not created.\033[0m"
    echo "Please try running the setup script again."
    exit 1
  fi
else
  echo -e "\n\033[1mGoogle Drive Authentication Required\033[0m"
  echo "EXACTLY WHAT YOU NEED TO DO:"
  echo "1. Go to https://console.cloud.google.com/"
  echo "2. Create a new project or select an existing one"
  echo "3. Enable the Google Drive API"
  echo "4. Configure an OAuth consent screen (internal is fine for testing)"
  echo "5. Add OAuth scope https://www.googleapis.com/auth/drive.readonly"
  echo "6. Create an OAuth Client ID for application type 'Desktop App'"
  echo "7. Download the JSON file"
  echo "8. Save the downloaded file as $CREDENTIALS_DIR/credentials.json"
  echo ""
  echo "The credentials.json file should look like this:"
  echo '{
  "installed": {
    "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
    "project_id": "YOUR_PROJECT_ID",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "YOUR_CLIENT_SECRET",
    "redirect_uris": ["http://localhost"]
  }
}'
  echo -e "\nAfter saving the credentials file, run this setup script again."
  exit 1
fi

# Print setup completion message
print_setup_complete \
  "Google Drive" \
  "" \
  "- gdrive_search: Search for files in Google Drive"

echo -e "\nGoogle Drive MCP server setup complete!"
echo -e "You can now use the Google Drive MCP server with Amazon Q or other MCP clients."
