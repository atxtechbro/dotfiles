# Git Worktree Workflow

Suppose you need to work on multiple tasks simultaneously with complete code isolation between Claude Code instances. Git worktrees provide this isolation.

**IMPORTANT**: Use git MCP tools instead of bash commands when possible. The `repo_path` parameter acts like `git -C` for worktrees.

1. `mkdir -p ~/ppv/pillars/dotfiles/worktrees`
2. Create worktree:
   - **New branch**: Use `mcp__git__git_worktree_add` with `create_branch: true`
   - **Existing branch**: Use `mcp__git__git_worktree_add` with branch name
3. Initialize worktree environment (if working on dotfiles repo): 
   - `cd` into worktree and run `source setup.sh`
   - This ensures PATH and environment are configured for the worktree context
   - Skip this step for other repositories that don't have setup.sh
4. Work in worktree: Pass worktree path as `repo_path` to MCP tools (no `cd` needed!)
5. Commit, push, create PR as normal
6. Ask for any pr feedback and address if any
7. Cleanup: Use `mcp__git__git_worktree_remove`
