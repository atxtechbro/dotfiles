#!/bin/bash

# =========================================================
# FILESYSTEM MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Filesystem MCP server
# This script is called by the MCP system during normal operation
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-filesystem-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# USAGE: The filesystem MCP server requires at least one allowed directory
# By default, we allow access to the user's home directory ($HOME)
# 
# To restrict access to specific directories only, set MCP_FILESYSTEM_RESTRICT_DIRS
# environment variable as a colon-separated list of allowed directories
# Example: export MCP_FILESYSTEM_RESTRICT_DIRS="/projects:/data"
#
# When MCP_FILESYSTEM_RESTRICT_DIRS is set, $HOME will NOT be included automatically

# Container mount point for home directory
CONTAINER_HOME="/home/user"

# Set default allowed directory to container home
if [ -n "$MCP_FILESYSTEM_RESTRICT_DIRS" ]; then
  # User wants to restrict access to specific directories
  IFS=':' read -ra ALLOWED_DIRS <<< "$MCP_FILESYSTEM_RESTRICT_DIRS"
else
  # Default to container home directory which maps to $HOME
  ALLOWED_DIRS=("$CONTAINER_HOME")
fi

# Run the Filesystem MCP server with allowed directories
exec docker run -i --rm \
  -v "$HOME:$CONTAINER_HOME" \
  --network=host \
  mcp/filesystem "${ALLOWED_DIRS[@]}"
