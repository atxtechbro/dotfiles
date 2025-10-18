# Worktree Troubleshooting Guide

## Known Failure Modes (From Crisis Learning)

### Dirty main
**Problem**: Worktree inherits untracked files → empty PR
**Solution**: Always stash or commit changes before creating worktree

### Wrong base commit
**Problem**: Local main ahead of origin → PR shows no diff
**Solution**: Always fetch and verify main is up-to-date with origin/main

### Wrong file paths
**Problem**: Files created in main, not worktree → empty commits
**Solution**: Always use full worktree path for all file operations

### OSE Principle violation
**Problem**: Not verifying GitHub PR diff before creating PR
**Solution**: Always run `mcp__git__git_diff target: origin/main` before creating PR
**Reference**: [OSE Principle](../../knowledge/principles/ose.md) - Only GitHub PR diff matters for review

### Broken symlinks
**Problem**: Running setup.sh from worktree creates symlinks that break when worktree is deleted
**Solution**: Never run `source setup.sh` from worktree - only from main repository
**Note**: setup.sh automatically detects and fixes broken symlinks from deleted worktrees