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

# Run the Filesystem MCP server
# Note: This server doesn't require API keys as it interacts with the local filesystem
exec docker run -i --rm \
  -v "$HOME:/home/user" \
  --network=host \
  mcp/filesystem
