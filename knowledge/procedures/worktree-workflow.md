# Git Worktree Workflow

Use git worktrees to work on multiple issues/features in parallel without branch switching.

1. `mkdir -p worktrees`
2. `git worktree add worktrees/issue-<NUMBER> -b <type>/<description>-<NUMBER>`
   - Use branch naming conventions: `feature/`, `fix/`, `docs/`, `refactor/`, etc.
3. Work with files using: `git -C worktrees/issue-<NUMBER>` for all git commands
4. Edit files with absolute paths when needed
5. Commit and push: 
   ```bash
   git -C worktrees/issue-<NUMBER> add -A
   git -C worktrees/issue-<NUMBER> commit -m "..."
   git -C worktrees/issue-<NUMBER> push -u origin <type>/<description>-<NUMBER>
   ```
6. Cleanup: `git worktree remove worktrees/issue-<NUMBER> --force`

**Key point**: Use `git -C <path>` to run git commands in any worktree without changing directories.
