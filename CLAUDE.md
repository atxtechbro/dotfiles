# AI Assistant Guide - Claude CLI

This file contains guidance for Claude CLI when interacting with this repository.


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

## GitHub Issues Formatting
- Same rule applies for GitHub issues - use actual line breaks, not escape sequences
- Example: `gh issue create --title "Title" --body "First line.` (press Enter) `Second line."` ✓
- NOT: `gh issue create --title "Title" --body "First line.\n\nSecond line."` ✗
- Keep issue descriptions to 21 lines or less (or use Fibonacci numbers: 1, 2, 3, 5, 8, 13, 21)
- Prefer concise issues with less context over verbose ones
- Treat GitHub issues as discussion points and suggestions, not strict mandates

## Quick CLAUDE.md Updates
- For quick updates to this file, use the standardized branch name: `docs/update-claude-guidance`
- Command: `git checkout main && git pull && git checkout -b docs/update-claude-guidance`

## Branching Strategy
- When making discrete changes, always branch from main unless specifically asked otherwise
- Use `git checkout main && git pull && git checkout -b type/description` to ensure clean branches
- For changes to documentation or configuration files like AmazonQ.md, especially prefer branching from main
- This prevents unintended changes from feature branches being included in your PR
- NEVER merge into main or push directly to main branch
- Commit early and often on your feature branch with descriptive commit messages
- For any changes to CLAUDE.md, always use the branch name `docs/update-claude-guidance`
- Use conventional commit format: `<type>[optional scope]: message` (e.g., `feat(tmux): add new shortcut for session switching`)
- Good scope choices add context about what component is being modified (e.g., bash, nvim, tmux, git)

## Commit Message Structure
- First line: Write a concise summary following conventional commits format
- Body: Expand on the change with more details if needed
- Reference PRINCIPLES.md: When a change aligns with Working Procedures from PRINCIPLES.md, cite it in the footer
- Example commit structure:
  ```
  feat(bash): add new alias for directory navigation
  
  Add shortcut 'gp' to navigate to projects directory and list contents
  This improves workflow efficiency for frequent project switching
  
  Working-Procedure: Standardization
  ```
- Common Working Procedures to reference:
  - Systems Thinking
  - Subtraction Creates Value
  - Standardization
  - Living Documentation
  - Focus And Clarity
  - 95 Percent Rule
- Use the exact name of the Working Procedure as it appears in PRINCIPLES.md
- Multiple procedures can be referenced with multiple trailer lines

Feel free to add your discoveries and insights below as you learn:

- Always use `uv` instead of `pip` for Python package management (e.g., `uv pip install package-name` not `pip install package-name`)

