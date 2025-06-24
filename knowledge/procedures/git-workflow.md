# Git Workflow Rules

## MCP Git Tools Usage
**IMPORTANT**: Use `mcp__git__*` tools instead of bash commands.
- **Time Saver**: Use `mcp__git__git_stage_commit_push` for the common add→commit→push workflow
- **Complex Workflows**: Use `mcp__git__git_batch` to chain multiple git operations

## Commit Standards
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., api, ui, auth, config, docs)
- Use `Principle: <slug>` trailer when work resonates with a specific principle (e.g., `Principle: subtraction-creates-value`, `Principle: versioning-mindset`, `Principle: systems-stewardship`)
- Commit early and often with meaningful changes

## Branch Management
- Use branch naming pattern: `type/description` (e.g., `feature/add-authentication`, `fix/login-bug`)
- If there's a related issue, suffix with issue number: `type/description-123` (e.g., `feature/add-authentication-512`)
- Use short-lived branches for complex tasks
- Keep changes small and frequent
- Never push directly to main - always use feature branches

## Common Errors to Avoid
- Don't thank self when closing your own PRs
