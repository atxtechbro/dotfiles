# Git Worktree Workflow

Suppose you need to work on multiple tasks simultaneously with complete code isolation between Claude Code instances. Git worktrees provide this isolation.

**PRINCIPLE**: Start worktrees from the same commit GitHub will use for the PR diff (usually origin/main).

**CRITICAL**: Empty PR Prevention - Multiple failure modes discovered through painful experience.

## Pre-flight Checks (REQUIRED)
1. **Sync with origin**: `git fetch && git status` - ensure local main == origin/main
2. **Clean workspace**: No untracked files or uncommitted changes in main
3. **Verify starting point**: Worktree must branch from origin/main, not local main

## Procedure
1. `mkdir -p ~/ppv/pillars/dotfiles/worktrees`
2. Create worktree from CLEAN origin/main:
   - **New branch**: Use `mcp__git__git_worktree_add` with `create_branch: true`
   - **Existing branch**: Use `mcp__git__git_worktree_add` with branch name
3. **CRITICAL**: Do NOT run `source setup.sh` from worktree - creates broken symlinks
   - Only use worktree for isolated development, not environment setup
   - setup.sh automatically detects and fixes broken symlinks from deleted worktrees
4. **CRITICAL**: ALL file operations must use worktree paths
5. Work in worktree: Pass worktree path as `repo_path` to MCP tools
6. **Before commit**: Verify files exist in worktree directory
7. **CRITICAL**: Check diff vs origin/main - `mcp__git__git_diff target: origin/main`
8. **After PR creation**: Immediately verify PR has content with `mcp__github-read__get_pull_request_files`
9. Cleanup: Use `mcp__git__git_worktree_remove`

## Known Failure Modes (From Crisis Learning)
- **Dirty main**: Worktree inherits untracked files → empty PR
- **Wrong base commit**: Local main ahead of origin → PR shows no diff
- **Wrong file paths**: Files created in main, not worktree → empty commits
- **MCP git tool failures**: False success reporting on failed commits
- **OSE Principle**: Only GitHub PR diff matters for review - must verify before creating PR
- **CRITICAL DISCOVERY**: MCP git tools fundamentally broken - use GitHub API direct push instead
- **Broken symlinks**: Running setup.sh from worktree creates symlinks that break when worktree is deleted
