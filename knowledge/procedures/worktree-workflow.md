# Git Worktree Workflow

Suppose you need to work on multiple tasks simultaneously with complete code isolation between Claude Code instances. Git worktrees provide this isolation.

**PRINCIPLE**: Start worktrees from the same commit GitHub will use for the PR diff (usually origin/main).

**IMPORTANT**: Use git MCP tools instead of bash commands when possible. The `repo_path` parameter acts like `git -C` for worktrees.

1. `mkdir -p ~/ppv/pillars/dotfiles/worktrees`
2. Create worktree:
   - **New branch**: Use `mcp__git__git_worktree_add` with `create_branch: true`
   - **Existing branch**: Use `mcp__git__git_worktree_add` with branch name
3. Initialize worktree environment (if working on dotfiles repo): 
   - **CRITICAL**: Do NOT run `source setup.sh` from worktree - creates broken symlinks
   - Only use worktree for isolated development, not environment setup
   - setup.sh automatically detects and fixes broken symlinks from deleted worktrees
4. Work in worktree: Pass worktree path as `repo_path` to MCP tools (no `cd` needed!)
5. Commit, push, create PR as normal
6. Ask for any pr feedback and address if any
7. Cleanup: Use `mcp__git__git_worktree_remove`
