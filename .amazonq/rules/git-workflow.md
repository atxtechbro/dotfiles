# Git Workflow Rules

## Commit Standards
- **IMPORTANT: NEVER commit directly to the main branch**
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., api, ui, auth, config, docs)
- Commit early and often with meaningful changes

## Branch Management
- Use branch naming pattern: `type/description` (e.g., `feature/add-authentication`, `fix/login-bug`)
- If there's a related issue, suffix with issue number: `type/description-123` (e.g., `feature/add-authentication-512`)
- Use short-lived branches for complex tasks
- Keep changes small and frequent

## Development Approach
- Do, don't explain – Execute tasks directly rather than describing how to do them

## Common Errors to Avoid
- Don't thank self when closing your own PRs
