#!/bin/bash

# =========================================================
# FILESYSTEM MCP SETUP SCRIPT
# =========================================================
# PURPOSE: One-time setup script for the Filesystem MCP server
# This script builds the Docker image and updates the configuration
# 
# RELATIONSHIP: This is the one-time setup script that prepares your
# environment. The filesystem-mcp-wrapper.sh script is the runtime
# component that gets executed by the MCP system.
# =========================================================

# Source the utility functions
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils/mcp-setup-utils.sh"

echo "Setting up Filesystem MCP server..."

# Check prerequisites
check_docker_installed
check_dotfiles_repo
REPO_ROOT=$(get_repo_root)

# Setup MCP servers repository
setup_mcp_servers_repo

# Build Docker image
build_mcp_docker_image "filesystem"

# Note: The mcp.json configuration is now managed directly in the repository
# and doesn't need to be updated by this script

# Print setup completion message
print_setup_complete \
  "Filesystem" \
  "" \
  "- fs_read: Read files and directories
- fs_write: Create and modify files
- fs_delete: Delete files and directories
- fs_move: Move or rename files and directories
- fs_copy: Copy files and directories
- fs_list: List directory contents
- fs_search: Search for files and directories"
