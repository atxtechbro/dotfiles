# Git Workflow Rules

## MCP Git Tools Usage
**IMPORTANT**: Use the git MCP server tools instead of bash commands:
- `mcp__git__git_status` - Check repository status
- `mcp__git__git_add` - Stage files
- `mcp__git__git_commit` - Commit changes
- `mcp__git__git_create_branch` - Create new branches
- `mcp__git__git_checkout` - Switch branches
- `mcp__git__git_push` - Push with upstream tracking
- `mcp__git__git_log` - View commit history
- `mcp__git__git_diff*` - View changes

These tools provide structured logging and better error handling than raw bash commands.

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

## Common Errors to Avoid
- Don't thank self when closing your own PRs
