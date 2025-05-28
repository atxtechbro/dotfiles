#!/bin/bash

# Git MCP Server Wrapper
# This script provides a consistent interface for different Git MCP server implementations
# Following the "spilled coffee principle" for reproducible environments

# Configuration
ACTIVE_IMPL=$(cat ~/.config/mcp/active-implementations/git 2>/dev/null || echo "kzms")
MCP_SERVERS_DIR=~/.local/share/mcp-servers
VENVS_DIR=~/ppv/pipelines/venvs/mcp-servers

# Check if virtual environment exists for active implementation
if [ -d "$VENVS_DIR/git-$ACTIVE_IMPL" ]; then
  PYTHON_BIN="$VENVS_DIR/git-$ACTIVE_IMPL/bin/python"
else
  PYTHON_BIN="python"
fi

# Implementation paths (in priority order)
IMPLEMENTATIONS=(
  "$MCP_SERVERS_DIR/python/git/$ACTIVE_IMPL/src/mcp_server_git/__main__.py"
  "$MCP_SERVERS_DIR/typescript/git/$ACTIVE_IMPL/dist/index.js"
  "$MCP_SERVERS_DIR/binary/git/$ACTIVE_IMPL"
)

# Find and execute the first available implementation
for impl in "${IMPLEMENTATIONS[@]}"; do
  if [ -f "$impl" ]; then
    case "$impl" in
      *.py)
        exec "$PYTHON_BIN" "$impl" "$@"
        ;;
      *.js)
        exec node "$impl" "$@"
        ;;
      *)
        exec "$impl" "$@"
        ;;
    esac
  fi
done

# Fallback to installed packages
if [ "$ACTIVE_IMPL" = "kzms" ] && [ -d "$VENVS_DIR/git-kzms" ]; then
  exec "$VENVS_DIR/git-kzms/bin/python" -m mcp_server_git "$@"
elif [ "$ACTIVE_IMPL" = "kzms" ]; then
  exec uvx run mcp_server_git "$@"
elif [ "$ACTIVE_IMPL" = "cyanheads" ]; then
  exec npx git-mcp-server "$@"
else
  echo "Error: No implementation found for git MCP server ($ACTIVE_IMPL)"
  exit 1
fi
