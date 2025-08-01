# Git Worktree Workflow

Use git worktrees for complete code isolation between simultaneous tasks. Start from origin/main to prevent empty PRs.

**When to use**: Working on multiple issues simultaneously, need isolated development environments
**Critical**: Pre-flight checks prevent empty PRs - fetch, clean workspace, verify starting point
**Details**: See [worktree-troubleshooting.md](/docs/procedures/worktree-troubleshooting.md) for failure modes