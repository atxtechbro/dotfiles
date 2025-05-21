#!/bin/bash

# =========================================================
# FILESYSTEM MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the Filesystem MCP server
# This script is called by the MCP system during normal operation
# =========================================================

# Run the Filesystem MCP server with the user's home directory
# This approach uses npx directly and works across different computers
# with different usernames by using $HOME
exec npx -y @modelcontextprotocol/server-filesystem "$HOME"