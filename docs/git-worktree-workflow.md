# Git Worktree Workflow (Beta - Imperfect System)

We know very little about worktrees. This is an admittedly imperfect system to be improved upon later per Versioning Mindset.

## Steps

1. `mkdir -p ~/ppv/pillars/worktrees/dotfiles`
2. `cd ~/ppv/pillars/dotfiles && git worktree add ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work in worktree: `cd ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER>`
4. Commit, push, create PR as normal
5. Cleanup: `cd ~/ppv/pillars/dotfiles && git worktree remove ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> --force`

## Quirks Found

- Must use full paths
- Cleanup requires returning to main repo directory

---

*First edition - will improve with experience*
