# atxtechbro Git MCP Server

A personalized Git workflow MCP server integrated into dotfiles for faster iteration and command chaining experiments.

## Overview

This is a customized version of the git-mcp-server that has been migrated into the dotfiles repository as part of the P.P.V system (Pillars, Pipelines, Vaults). It serves as an experimental pillar for bringing MCP tools directly into dotfiles alongside other developer tooling.

## Key Features

- **Comprehensive Tool-Level Logging**: Every git operation is logged with detailed context
- **Personalized for atxtechbro workflow**: Optimized for specific development patterns
- **Integrated with dotfiles**: Lives alongside other development tools for unified management
- **Fast feedback loops**: Designed to chain commands together and reduce AI response cycles

## Available Git Tools

| Tool | Description | Logging |
|------|-------------|---------|
| `git_status` | Shows working tree status | ✅ |
| `git_diff_unstaged` | Shows unstaged changes | ✅ |
| `git_diff_staged` | Shows staged changes | ✅ |
| `git_diff` | Shows differences between branches/commits | ✅ |
| `git_commit` | Records changes to repository | ✅ |
| `git_add` | Adds files to staging area | ✅ |
| `git_reset` | Unstages all staged changes | ✅ |
| `git_log` | Shows commit history | ✅ |
| `git_create_branch` | Creates new branch | ✅ |
| `git_checkout` | Switches branches | ✅ |
| `git_show` | Shows commit contents | ✅ |
| `git_worktree_add` | Add a new worktree for parallel development | ✅ |
| `git_worktree_remove` | Remove a worktree | ✅ |
| `git_worktree_list` | List all worktrees | ✅ |
| `git_push` | Push commits to remote repository | ✅ |
| `git_pull` | Pull changes from remote repository | ✅ |
| `git_fetch` | Fetch updates from remote repository without merging | ✅ |
| `git_merge` | Merge branches with support for different strategies | ✅ |
| `git_remote` | Manage remote repositories | ✅ |
| `git_batch` | Execute multiple git commands in sequence | ✅ |
| `git_rebase` | Rebase current branch onto another branch | ✅ |
| `git_stash` | Stash the changes in a dirty working directory away | ✅ |
| `git_stash_pop` | Apply and remove stashed changes | ✅ |

### Git Rebase Tool

The `git_rebase` tool supports maintaining linear history and reorganizing commits:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `onto`: Branch to rebase onto (required for new rebase)
- `interactive`: Enable interactive rebase (limited support)
- `continue_rebase`: Continue an in-progress rebase
- `skip`: Skip current commit during rebase
- `abort`: Abort an in-progress rebase

**Usage Examples:**
- Start rebase: `{"repo_path": ".", "onto": "main"}`
- Continue after resolving conflicts: `{"repo_path": ".", "continue_rebase": true}`
- Skip problematic commit: `{"repo_path": ".", "skip": true}`
- Abort rebase: `{"repo_path": ".", "abort": true}`

**Note:** Interactive rebase is not fully supported in MCP environment due to editor limitations.

### Git Fetch Tool

The `git_fetch` tool allows updating remote refs without merging, essential for checking remote changes:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `remote`: Remote to fetch from (default: "origin")
- `branch`: Specific branch to fetch (optional)
- `all`: Fetch all remotes (default: false)
- `prune`: Remove deleted remote branches (default: false)
- `tags`: Fetch tags (default: true)

**Usage Examples:**
- Fetch default remote: `{"repo_path": "."}`
- Fetch specific branch: `{"repo_path": ".", "branch": "feature-branch"}`
- Fetch all remotes with pruning: `{"repo_path": ".", "all": true, "prune": true}`
- Fetch without tags: `{"repo_path": ".", "tags": false}`

### Git Stash Tool

The `git_stash` tool provides comprehensive stash management for temporary work storage:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `action`: Operation to perform (default: "push")
  - `"push"`: Save current changes to stash
  - `"list"`: Show all stashes
  - `"show"`: Display contents of a stash
  - `"apply"`: Apply stash without removing it
  - `"pop"`: Apply and remove stash
  - `"drop"`: Remove a specific stash
  - `"clear"`: Remove all stashes
- `message`: Message for stash (optional, for push action)
- `stash_ref`: Stash reference like "stash@{0}" (optional, for pop/apply/drop/show)
- `keep_index`: Keep staged changes (default: false, for push)
- `include_untracked`: Include untracked files (default: false, for push)

**Usage Examples:**
- Create stash with message: `{"repo_path": ".", "action": "push", "message": "WIP: feature implementation"}`
- List all stashes: `{"repo_path": ".", "action": "list"}`
- Show specific stash: `{"repo_path": ".", "action": "show", "stash_ref": "stash@{1}"}`
- Apply without removing: `{"repo_path": ".", "action": "apply", "stash_ref": "stash@{0}"}`
- Drop specific stash: `{"repo_path": ".", "action": "drop", "stash_ref": "stash@{2}"}`
- Clear all stashes: `{"repo_path": ".", "action": "clear"}`

### Git Stash Pop Tool

The `git_stash_pop` tool is a convenience wrapper for applying and removing stashed changes:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `stash_ref`: Specific stash to pop (optional, defaults to "stash@{0}")
- `index`: Restore staged changes (default: false)

**Usage Examples:**
- Pop latest stash: `{"repo_path": "."}`
- Pop specific stash: `{"repo_path": ".", "stash_ref": "stash@{2}"}`
- Pop with index restoration: `{"repo_path": ".", "index": true}`

**Note:** If merge conflicts occur during pop, the stash is not removed and must be resolved manually.

## Logging Implementation

### Tool-Level Logging
Each git tool call is logged to `~/mcp-tool-calls.log` with:
- **Timestamp**: When the operation occurred
- **Server**: atxtechbro-git-mcp-server
- **Tool**: Specific git tool used
- **Status**: SUCCESS or ERROR
- **Branch**: Current git branch context
- **Details**: Tool-specific operation details
- **Parameters**: Full JSON of arguments passed

### Example Log Entry
```
2025-06-18 12:58:30: [atxtechbro-git-mcp-server] TOOL_CALL: git_status | STATUS: SUCCESS | BRANCH: feature/migrate-mcp-servers-450 | DETAILS: Retrieved repository status | PARAMS: {"repo_path": "/Users/morgan.joyce/ppv/pillars/dotfiles"}
```

### Viewing Logs
Use the `check-mcp-logs` utility:
```bash
# Show all logs
check-mcp-logs

# Show only tool calls
check-mcp-logs --tools

# Follow logs in real-time
check-mcp-logs --follow

# Show last 50 lines
check-mcp-logs --lines 50
```

## Installation

The git-mcp-server is automatically set up via the setup script:

```bash
cd ~/ppv/pillars/dotfiles/mcp
bash setup-git-mcp.sh
```

This script:
1. Creates a Python virtual environment
2. Installs the personalized package (`atxtechbro-git-mcp-server`)
3. Sets up executable permissions
4. Creates necessary symlinks

## Architecture

```
mcp/servers/git-mcp-server/
├── src/mcp_server_git/
│   ├── __init__.py          # Entry point and CLI
│   ├── __main__.py          # Main module runner
│   ├── server.py            # Core MCP server with logging
│   └── logging_utils.py     # Tool-level logging utilities
├── pyproject.toml           # Personalized package metadata
└── README.md               # This file
```

## Experimental Nature

This implementation is experimental and designed for:
- **Command chaining**: Combining multiple git operations in single AI interactions
- **Faster iteration**: Reducing the need for multiple AI response cycles
- **Enhanced debugging**: Comprehensive logging for troubleshooting
- **Workflow optimization**: Tailored to specific development patterns

The server may be removed in favor of direct bash commands if experiments prove unfruitful, following the principle that "bash by itself was actually outperforming this server as is."

## Integration with Dotfiles

As part of the dotfiles pillar, this server:
- Lives alongside other development tools
- Shares the same logging infrastructure
- Benefits from unified secret management
- Follows the same setup and maintenance patterns

This integration supports the "Snowball Method" of continuous knowledge accumulation and the "Spilled Coffee Principle" of reproducible environments.

## Development

To modify the server:
1. Edit files in `src/mcp_server_git/`
2. Reinstall with `bash setup-git-mcp.sh`
3. Test changes and check logs with `check-mcp-logs --tools`
4. Commit changes to the dotfiles repository

The source code is version controlled as part of the dotfiles repository, enabling rapid iteration and experimentation.
