# Git MCP Server - Flag-Based Read/Write Split

## Overview
The Git MCP server now supports a `--read-only` flag to restrict operations:
- `git-read`: Safe read-only operations (runs with `--read-only` flag)
- `git-write`: Full operations (runs without restrictions)

## Architecture
This implementation follows the same pattern as the GitHub MCP server:
- Single Python codebase with conditional behavior
- Flag passed through wrapper scripts
- Tool filtering based on mode at runtime

## Implementation Details

### Entry Point
The `__init__.py` accepts a `--read-only` flag:
```python
@click.option("--read-only", is_flag=True, help="Run in read-only mode (no write operations)")
```

### Tool Filtering
Tools are categorized into READ_ONLY_TOOLS and WRITE_TOOLS sets. The server:
1. Filters available tools in `list_tools()` based on mode
2. Validates tool usage in `call_tool()` before execution
3. Provides special handling for restricted tools

### Special Cases
- **git_remote**: Limited to "list" action in read-only mode
- **git_branch_delete**: Blocks remote deletion in read-only mode  
- **git_batch**: Validates all commands are read-only tools
- **git_fetch**: Allowed in read-only (only downloads data)

## Read-Only Tools
- git_status, git_diff_*, git_log, git_show
- git_worktree_list, git_reflog, git_blame
- git_describe, git_shortlog
- git_remote (list only), git_fetch
- git_branch_delete (local only)

## Write Tools
- git_commit, git_add, git_reset
- git_create_branch, git_checkout
- git_push, git_pull, git_merge
- git_rebase, git_stash, git_cherry_pick
- git_revert, git_reset_hard, git_clean, git_bisect

## Migration
Users need to:
1. Update their MCP client config to use new server names
2. Replace `git` with `git-read` for safe operations
3. Manually enable `git-write` when needed

## Benefits
- Consistent with GitHub server approach
- Single codebase to maintain
- Easy to extend with new tools
- Clear security boundaries