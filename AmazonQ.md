## Commit early and often
Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
Always include blank line at end of files

## Common Errors to Avoid
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Don't thank yourself when closing your own PRs

## GitHub CLI Best Practices
- Always use text files and pipe them to GitHub CLI commands for multi-line content
- Example: `echo "Your comment text here" > comment.txt && gh pr comment <number> -F comment.txt` ✓
- This approach follows Unix philosophy and avoids escape sequence issues
- For quick one-liners, you can still use: `gh pr comment <number> -b "Brief comment"`
- Keep PR descriptions to 34 lines or less to ensure they display properly in all contexts

## GitHub Issues Best Practices
- Use the same text file approach for GitHub issues
- Example: `echo "Issue description" > issue.txt && gh issue create --title "Title" -F issue.txt` ✓
- Keep issue descriptions to 18 lines or less when creating new issues to allow room for future discoveries and context
- Never edit an issue if it would cause the total length to exceed 55 lines - create a new issue instead
- Prefer concise issues with less context over verbose ones
- Treat GitHub issues as discussion points and suggestions, not strict mandates

## Quick AmazonQ.md Updates
- use branch name: `docs/update-amazonq-guidance`

## Debugging Amazon Q CLI
- Log files are stored in `/tmp/q-logs/` and `~/.amazonq/logs/` (if it exists)
- Check logs immediately after running commands as they may be cleaned up automatically
  
## Branching Strategy
- Pull Request based workflow (GitHub)
- Tracer bullet vibe coding development style (atomic commits)
- When making discrete changes, always branch from main unless specifically asked otherwise
- Use `git checkout main && git pull && git checkout -b type/description` to ensure clean branches
- For changes to documentation or configuration files like AmazonQ.md, especially prefer branching from main
- This prevents unintended changes from feature branches being included in your PR
- NEVER merge into main or push directly to main branch
- Good scope choices add context about what component is being modified (e.g., bash, nvim, tmux, git)
