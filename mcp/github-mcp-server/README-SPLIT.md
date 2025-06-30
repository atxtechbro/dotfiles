# GitHub MCP Server - Read/Write Split

## Overview
The GitHub MCP server has been split into two distinct modes:
- `github-read`: Read-only operations (runs with `--read-only` flag)
- `github-write`: Write-only operations (runs with `--write-only` flag)

## Architecture
The GitHub server uses the same binary with different flags:
- Both wrappers execute the same `github-mcp-server` binary
- The read wrapper adds `--read-only` flag
- The write wrapper adds `--write-only` flag
- This ensures no overlap between read and write operations

## Read-Only Operations (github-read)
When running with `--read-only`, the server restricts to:
- All get_* operations (issues, PRs, commits, etc.)
- All list_* operations
- All search_* operations
- Notification viewing (but not dismissing/marking as read in strict mode)

## Write Operations (github-write)
When running with `--write-only`, the server restricts to write operations only:
- All create_* operations
- All update_* operations
- All delete_* operations
- merge_pull_request, push_files
- Workflow runs and management
- Notification management (dismissing, marking as read)
- Note: Read operations are NOT available in this mode

## Security Notes
- The GitHub server has built-in read-only and write-only mode support
- The `--read-only` and `--write-only` flags are enforced at the toolset level
- Each toolset separates read and write tools internally
- Clear separation prevents accidental exposure of read operations in write mode

## Migration
Users need to:
1. Update their MCP client config to use new server names
2. Replace `github` with `github-read` for safe operations
3. Manually enable `github-write` when needed