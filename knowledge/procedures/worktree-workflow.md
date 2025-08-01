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
4. **Set working directory**: Use full worktree path (e.g., `/home/user/ppv/pillars/dotfiles/worktrees/feature-X/`) as prefix for ALL file operations to prevent empty PRs
5. Work in worktree: Pass worktree path as `repo_path` to MCP tools
6. **CRITICAL**: Check diff vs origin/main - `mcp__git__git_diff target: origin/main`
7. Cleanup: Use `mcp__git__git_worktree_remove`

## Known Failure Modes (From Crisis Learning)
- **Dirty main**: Worktree inherits untracked files → empty PR
- **Wrong base commit**: Local main ahead of origin → PR shows no diff
- **Wrong file paths**: Files created in main, not worktree → empty commits
- **[OSE Principle](../principles/ose.md)**: Only GitHub PR diff matters for review - must verify before creating PR
- **Broken symlinks**: Running setup.sh from worktree creates symlinks that break when worktree is deleted
- **Think-tank content in worktrees**: Never add think-tank notes or personal content to worktree locations - they're ephemeral and will be lost. Always use the main repository at `/think-tank/`

## See Also
- [Close Issue Procedure](close-issue-procedure.md) - Full workflow using worktrees for issue implementation
