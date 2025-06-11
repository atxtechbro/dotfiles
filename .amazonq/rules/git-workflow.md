# Git Workflow Rules

## Commit Standards
- **IMPORTANT: NEVER commit directly to the main branch**
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., bash, mcp, tmux, git)
- Commit early and often with meaningful changes

## Branch Management
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Use short-lived branches for complex tasks
- Keep changes small and frequent – Encourage developers to commit small, incremental changes or features

## Development Process
- Pull Request based workflow (GitHub)
- Tracer bullet / vibe coding development style
- Maintain a robust test suite – A comprehensive, well-maintained test suite is crucial
- Do, don't explain – Execute tasks directly rather than describing how to do them
- **Standard process**: 1) Start with clean working tree, 2) Create descriptive branch, 3) Make focused changes, 4) Commit and push, 5) Create PR with clear description

## Common Errors to Avoid
- Don't thank self when closing your own PRs
