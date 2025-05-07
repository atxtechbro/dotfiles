## Commit early and often
Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
Always include blank line at end of files

## Common Errors to Avoid
- CRITICAL: Never use escape sequences like `\n\n` in any text submitted through interfaces (PR comments, descriptions, issues, etc.) as they will appear LITERALLY AS THE CHARACTERS "\n\n"
- ALWAYS use actual line breaks by pressing Enter between lines for ALL text interfaces

## Quick AmazonQ.md Updates
- use branch name:
- `docs/update-amazonq-guidance`

## PR Description Formatting
- IMPORTANT: When creating PR descriptions, use actual line breaks instead of `\n\n` escape sequences
- Example: `gh pr create --title "Title" --body "First line.` (press Enter) `Second line."` ✓
- NOT: `gh pr create --title "Title" --body "First line.\n\nSecond line."` ✗
- Keep PR descriptions to 34 lines or less when using the GitHub CLI to ensure they display properly in all contexts

## GitHub Issues Formatting
- Don't use code snippets or anything potentially executeable, use pseudocode instead for text files. Assume mcp servers currently installed are broken.
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- For GitHub CLI comments use: `gh pr comment <number> -b "text"` (not `---comment`) # TODO: can mcp make this line deletable because it will be smarter?
- Don't thank yourself when closing your own PRs
- Same rule applies for GitHub issues - use actual line breaks, not escape sequences
- Example: `gh issue create --title "Title" --body "First line.` (press Enter) `Second line."` ✓
- NOT: `gh issue create --title "Title" --body "First line.\n\nSecond line."` ✗
- Keep issue descriptions to 18 lines or less when creating new issues to allow room for future discoveries and context
- Never edit an issue if it would cause the total length to exceed 55 lines - create a new issue instead
- Prefer concise issues with less context over verbose ones
- Treat GitHub issues as discussion points and suggestions, not strict mandates
  
## Branching Strategy
- Pull Request based workflow (GitHub)
- Tracer bullet vibe coding development style (atomic commits)
- When making discrete changes, always branch from main unless specifically asked otherwise
- Use `git checkout main && git pull && git checkout -b type/description` to ensure clean branches
- For changes to documentation or configuration files like AmazonQ.md, especially prefer branching from main
- This prevents unintended changes from feature branches being included in your PR
- NEVER merge into main or push directly to main branch
- Good scope choices add context about what component is being modified (e.g., bash, nvim, tmux, git)
