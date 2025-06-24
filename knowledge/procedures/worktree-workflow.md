# Git Worktree Workflow

Suppose you need to work on multiple tasks simultaneously with complete code isolation between Claude Code instances. Git worktrees provide this isolation.

1. `mkdir -p ~/ppv/pillars/dotfiles/worktrees`
2. `cd ~/ppv/pillars/dotfiles && git worktree add ~/ppv/pillars/dotfiles/worktrees/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work in worktree: `cd ~/ppv/pillars/dotfiles/worktrees/issue-<NUMBER>`
4. Commit, push, create PR as normal
5. Cleanup: `cd ~/ppv/pillars/dotfiles && git worktree remove ~/ppv/pillars/dotfiles/worktrees/issue-<NUMBER> --force`

**Quirks found**: Must use full paths, cleanup requires returning to main repo directory.
