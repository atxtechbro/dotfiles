# Git Worktree Workflow

Suppose you need to work on multiple tasks simultaneously with complete code isolation between Claude Code instances. Git worktrees provide this isolation.

1. `mkdir -p ~/ppv/pillars/dotfiles/worktrees`
2. Create worktree:
   - **New branch**: `git worktree add ~/ppv/pillars/dotfiles/worktrees/<worktree-name> -b <branch-name>`
   - **Existing branch**: `git worktree add ~/ppv/pillars/dotfiles/worktrees/<worktree-name> <branch-name>`
3. Work in worktree: `cd ~/ppv/pillars/dotfiles/worktrees/<worktree-name>`
4. Commit, push, create PR as normal
5. Ask for any pr feedback and address if any
6. Cleanup: `cd ~/ppv/pillars/dotfiles && git worktree remove ~/ppv/pillars/dotfiles/worktrees/<worktree-name> --force`
