# Git Worktree Workflow (Beta - Imperfect System)

We know very little about worktrees. This is an admittedly imperfect system to be improved upon later per Versioning Mindset.

1. `mkdir -p ~/ppv/pillars/dotfiles/worktrees`
2. `cd ~/ppv/pillars/dotfiles && git worktree add ~/ppv/pillars/dotfiles/worktrees/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work in worktree: `cd ~/ppv/pillars/dotfiles/worktrees/issue-<NUMBER>`
4. Commit, push, create PR as normal
5. Cleanup: `cd ~/ppv/pillars/dotfiles && git worktree remove ~/ppv/pillars/dotfiles/worktrees/issue-<NUMBER> --force`

**Quirks found**: Must use full paths, cleanup requires returning to main repo directory.
