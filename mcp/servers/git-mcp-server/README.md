# Git MCP Server

Personal Git MCP server integrated into dotfiles for faster iteration and command chaining.

## What It Does

Provides Git operations to AI agents via the MCP protocol with comprehensive tool-level logging.

## Architecture

## How It Works

1. The wrapper script `mcp/git-mcp-wrapper.sh` calls `.venv/bin/python -m mcp_server_git`
2. Every Git operation is logged with timestamp, tool name, status, and parameters
3. Logs viewable via `check-mcp-logs --tools`

## Available Tools

All standard Git operations: status, diff, commit, add, branch, checkout, push, pull, merge, rebase, stash, cherry-pick, and more. See `server.py` for the complete list.

## Maintenance

- Dependencies are in `.venv/` managed by the setup script
- To modify: edit files in `src/mcp_server_git/` and restart your MCP client
- Part of the dotfiles Snowball Method for continuous improvement
