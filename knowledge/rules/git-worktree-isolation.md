# Git Worktree Isolation

Worktrees start from ONE commit. Pick wrong = empty PR.

**The rule**: Start from origin/main, not local main
**Why**: GitHub compares against origin, not your local outdated copy
**Fix**: Can't. Start over. Do it right.

Check `git fetch && git status` BEFORE creating worktrees.