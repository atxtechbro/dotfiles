# Git MCP Server - Read/Write Split

## Overview
The Git MCP server has been split into two separate servers for enhanced security:
- `mcp-server-git-read`: Read-only operations (status, log, diff, etc.)
- `mcp-server-git-write`: Write operations (commit, push, reset, etc.)

## File Structure
```
src/mcp_server_git/
├── base.py          # Shared functionality and models
├── server_read.py   # Read-only server implementation
├── server_write.py  # Write server implementation
├── server.py        # Original unified server (for backward compatibility)
└── logging_utils.py # Logging utilities
```

## Read-Only Tools
- git_status, git_diff_*, git_log, git_show
- git_worktree_list, git_reflog, git_blame
- git_describe, git_shortlog
- git_remote (list action only)
- git_batch (read-only commands only)
- git_branch_delete (local only, no remote)

## Write Tools
- git_commit, git_add, git_reset
- git_create_branch, git_checkout
- git_worktree_add, git_worktree_remove
- git_push, git_pull, git_fetch, git_merge
- git_rebase, git_stash, git_cherry_pick
- git_revert, git_reset_hard, git_clean, git_bisect
- git_remote (all actions)
- git_batch (all commands)
- git_branch_delete (including remote)

## Usage
```bash
# Read-only server
mcp-server-git-read [repository_path]

# Write server
mcp-server-git-write [repository_path]
```

## Security Notes
- The read-only server validates that destructive operations are not performed
- git_branch_delete in read server blocks remote deletion
- git_remote in read server only allows list action
- git_batch validates allowed tools based on server type