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
| `git_cherry_pick` | Cherry-pick commits onto the current branch | ✅ |
| `git_reflog` | Show the reference log for recovery and history inspection | ✅ |
| `git_blame` | Show who last modified each line of a file | ✅ |
| `git_revert` | Create a new commit that undoes a previous commit | ✅ |
| `git_reset_hard` | Hard reset to a specific commit (DESTRUCTIVE) | ✅ |
| `git_branch_delete` | Delete local and optionally remote branches | ✅ |
| `git_clean` | Remove untracked files and directories (DESTRUCTIVE) | ✅ |
| `git_bisect` | Binary search to find commit that introduced a bug | ✅ |
| `git_describe` | Generate human-readable names for commits | ✅ |
| `git_shortlog` | Summarize git log by contributor | ✅ |

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

### Git Cherry Pick Tool

The `git_cherry_pick` tool allows applying specific commits from other branches:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `commits`: Single commit SHA or array of commits (required)
- `continue_pick`: Continue an in-progress cherry-pick
- `skip`: Skip current commit during cherry-pick
- `abort`: Abort an in-progress cherry-pick
- `no_commit`: Apply changes without creating commits
- `mainline_parent`: Parent number for merge commits (1 or 2)

**Usage Examples:**
- Pick single commit: `{"repo_path": ".", "commits": "abc123"}`
- Pick multiple commits: `{"repo_path": ".", "commits": ["abc123", "def456"]}`
- Continue after resolving conflicts: `{"repo_path": ".", "continue_pick": true}`
- Abort cherry-pick: `{"repo_path": ".", "abort": true}`

### Git Reflog Tool

The `git_reflog` tool provides access to the reference log for recovery operations:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `max_count`: Maximum number of entries to show (default: 30)
- `ref`: Specific reference to show reflog for (optional)

**Usage Examples:**
- Show default reflog: `{"repo_path": "."}`
- Show specific branch reflog: `{"repo_path": ".", "ref": "feature-branch"}`
- Show last 10 entries: `{"repo_path": ".", "max_count": 10}`

### Git Blame Tool

The `git_blame` tool shows line-by-line authorship information:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `file_path`: Path to the file to blame (required)
- `line_range`: Limit output to line range (e.g., "10,20")

**Usage Examples:**
- Blame entire file: `{"repo_path": ".", "file_path": "src/main.py"}`
- Blame specific lines: `{"repo_path": ".", "file_path": "src/main.py", "line_range": "100,150"}`

### Git Revert Tool

The `git_revert` tool creates new commits that undo previous commits:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `commit`: Commit SHA to revert (required)
- `no_edit`: Use default commit message
- `no_commit`: Apply changes without creating commit
- `mainline_parent`: Parent number for merge commits

**Usage Examples:**
- Revert commit: `{"repo_path": ".", "commit": "abc123"}`
- Revert without editing message: `{"repo_path": ".", "commit": "abc123", "no_edit": true}`
- Revert merge commit: `{"repo_path": ".", "commit": "abc123", "mainline_parent": 1}`

### Git Reset Hard Tool

The `git_reset_hard` tool performs a hard reset, discarding all changes:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `ref`: Reference to reset to (default: "HEAD")

**Usage Examples:**
- Reset to HEAD: `{"repo_path": "."}`
- Reset to specific commit: `{"repo_path": ".", "ref": "abc123"}`
- Reset to branch: `{"repo_path": ".", "ref": "origin/main"}`

**⚠️ WARNING:** This operation is destructive and will discard all uncommitted changes!

### Git Branch Delete Tool

The `git_branch_delete` tool removes local and optionally remote branches:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `branch_name`: Name of branch to delete (required)
- `force`: Force delete even if not merged
- `remote`: Delete remote branch as well

**Usage Examples:**
- Delete merged branch: `{"repo_path": ".", "branch_name": "feature-done"}`
- Force delete: `{"repo_path": ".", "branch_name": "abandoned-feature", "force": true}`
- Delete remote too: `{"repo_path": ".", "branch_name": "old-feature", "remote": true}`

### Git Clean Tool

The `git_clean` tool removes untracked files and directories:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `force`: Actually remove files (required for safety)
- `directories`: Also remove directories
- `ignored`: Also remove ignored files
- `dry_run`: Show what would be removed

**Usage Examples:**
- Dry run: `{"repo_path": ".", "dry_run": true}`
- Clean files: `{"repo_path": ".", "force": true}`
- Clean everything: `{"repo_path": ".", "force": true, "directories": true, "ignored": true}`

**⚠️ WARNING:** This operation is destructive! Always use dry_run first.

### Git Bisect Tool

The `git_bisect` tool performs binary search to find problematic commits:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `action`: Bisect action (required)
  - `"start"`: Start bisect session
  - `"bad"`: Mark commit as bad
  - `"good"`: Mark commit as good
  - `"skip"`: Skip current commit
  - `"reset"`: End bisect session
  - `"view"`: Show bisect status
- `commit`: Commit SHA for good/bad actions
- `bad_commit`: Bad commit for start action
- `good_commit`: Good commit for start action

**Usage Examples:**
- Start bisect: `{"repo_path": ".", "action": "start", "bad_commit": "HEAD", "good_commit": "v1.0"}`
- Mark as bad: `{"repo_path": ".", "action": "bad"}`
- Mark as good: `{"repo_path": ".", "action": "good", "commit": "abc123"}`
- End bisect: `{"repo_path": ".", "action": "reset"}`

### Git Describe Tool

The `git_describe` tool generates human-readable names from tags:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `commit`: Commit to describe (optional)
- `all`: Use all refs, not just tags
- `tags`: Use any tag, not just annotated
- `long`: Always use long format

**Usage Examples:**
- Describe HEAD: `{"repo_path": "."}`
- Describe commit: `{"repo_path": ".", "commit": "abc123"}`
- Use all tags: `{"repo_path": ".", "tags": true}`

### Git Shortlog Tool

The `git_shortlog` tool summarizes commits by author:

**Parameters:**
- `repo_path`: Path to the git repository (required)
- `numbered`: Sort by number of commits
- `summary`: Show only commit count
- `email`: Show email addresses
- `since`: Show commits since date
- `until`: Show commits until date

**Usage Examples:**
- Basic summary: `{"repo_path": "."}`
- Numbered list: `{"repo_path": ".", "numbered": true}`
- Last month: `{"repo_path": ".", "since": "1 month ago"}`
- Count only: `{"repo_path": ".", "summary": true, "numbered": true}`

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
