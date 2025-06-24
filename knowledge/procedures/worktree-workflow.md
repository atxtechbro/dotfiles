# Git Worktree Workflow (Beta - Imperfect System)

We know very little about worktrees. This is an admittedly imperfect system to be improved upon later per Versioning Mindset.

**Claude Code Compatible Version** (works within cd constraints):
1. `mkdir -p worktrees`
2. `git worktree add worktrees/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work with files using absolute paths: `/home/linuxmint-lp/ppv/pillars/dotfiles/worktrees/issue-<NUMBER>/...`
4. Commit and push: `git -C worktrees/issue-<NUMBER> add -A && git -C worktrees/issue-<NUMBER> commit -m "..." && git -C worktrees/issue-<NUMBER> push -u origin feature/<description>-<NUMBER>`
5. Cleanup: `git worktree remove worktrees/issue-<NUMBER> --force`

**Alternative: Using full paths with -C flag**:
1. `mkdir -p ~/ppv/pillars/worktrees/dotfiles`  
2. `git worktree add ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work with files using full paths: `~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER>/...`
4. All git commands use -C: `git -C ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> status`
5. Commit: `git -C ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> add -A && git -C ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> commit -m "..."`
6. Push: `git -C ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> push -u origin feature/<description>-<NUMBER>`
7. Cleanup: `git worktree remove ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> --force`

**Original Version** (for human use):
1. `mkdir -p ~/ppv/pillars/worktrees/dotfiles`
2. `cd ~/ppv/pillars/dotfiles && git worktree add ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> -b feature/<description>-<NUMBER>`
3. Work in worktree: `cd ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER>`
4. Commit, push, create PR as normal
5. Cleanup: `cd ~/ppv/pillars/dotfiles && git worktree remove ~/ppv/pillars/worktrees/dotfiles/issue-<NUMBER> --force`

**Quirks found**: 
- Claude Code cannot cd to parent directories, use -C flag with either relative (worktrees/...) or absolute paths (~/ppv/...) instead
- Git -C flag allows running git commands in any directory without changing working directory
