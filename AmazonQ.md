# AI Assistant Guide - Amazon Q

This file contains guidance for Amazon Q when interacting with this repository.

See [VIBE.md](./VIBE.md) for the Vibe Coding Manifesto that guides this repository.

## Common Errors to Avoid
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Follow Conventional Commits style (e.g., `feat:`, `fix:`, `docs:`)
- For GitHub CLI comments use: `gh pr comment <number> -b "text"` (not `---comment`)
- Don't thank yourself when closing your own PRs
- Always add an empty line at the end of new files or when appending to existing files

## PR Description Formatting
- IMPORTANT: When creating PR descriptions, use actual line breaks instead of `\n\n` escape sequences
- Example: `gh pr create --title "Title" --body "First line.` (press Enter) `Second line."` ✓
- NOT: `gh pr create --title "Title" --body "First line.\n\nSecond line."` ✗
- Keep PR descriptions to 34 lines or less when using the GitHub CLI to ensure they display properly in all contexts

## Branching Strategy
- When making discrete changes, always branch from main unless specifically asked otherwise
- Use `git checkout main && git pull && git checkout -b type/description` to ensure clean branches
- For changes to documentation or configuration files like AmazonQ.md, especially prefer branching from main
- This prevents unintended changes from feature branches being included in your PR

Feel free to add your discoveries and insights below as you learn:

- Always use `uv` instead of `pip` for Python package management (e.g., `uv pip install package-name` not `pip install package-name`)
- For Datadog CLI setup: `uv pip install datadog-cli` and store API keys in `~/.bash_secrets`
- 
