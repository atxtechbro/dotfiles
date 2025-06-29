# GitHub MCP Server - Read/Write Split

## Overview
The GitHub MCP server has been split into two modes using the existing `--read-only` flag:
- `github-read`: Read-only operations (runs with `--read-only` flag)
- `github-write`: Full operations (runs without restrictions)

## Architecture
Unlike the Git server split, the GitHub server uses the same binary with different flags:
- Both wrappers execute the same `github-mcp-server` binary
- The read wrapper adds `--read-only` flag
- The write wrapper runs without restrictions

## Read-Only Operations (github-read)
When running with `--read-only`, the server restricts to:
- All get_* operations (issues, PRs, commits, etc.)
- All list_* operations
- All search_* operations
- Notification viewing (but not dismissing/marking as read in strict mode)

## Write Operations (github-write)
Full access includes:
- All create_* operations
- All update_* operations
- All delete_* operations
- merge_pull_request, push_files
- Workflow runs and management
- Notification management

## Security Notes
- The GitHub server already has built-in read-only mode support
- The `--read-only` flag is enforced at the toolset level
- Each toolset separates read and write tools internally
- No code changes needed - just different launch flags

## Migration
Users need to:
1. Update their MCP client config to use new server names
2. Replace `github` with `github-read` for safe operations
3. Manually enable `github-write` when needed