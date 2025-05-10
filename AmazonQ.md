## We're following a tracer bullet development approach, therefore:

## Dotfiles Philosophy
- Follow the "spilled coffee" principle: anyone should be able to destroy their machine and be fully operational again that afternoon
- All configuration changes should be reproducible across machines
- Avoid manual, one-off commands. Instead, commit to setup scripts and run them (automation mindset)
- Always create setup scripts for file operations instead of ad-hoc terminal commands
- Use installation scripts that detect and create required directories
- Prefer symlinks managed by setup scripts over manual file copying
- Document all dependencies and installation steps in README files
- For dotfiles, use setup scripts for symlinks rather than manual linking

## Tips

### ⚠️ CRITICAL: Commit early and often but NEVER EVER PUSH ⚠️
- **LOCAL DEVELOPMENT ONLY** - All changes should remain on your local machine
- **ZERO EXCEPTIONS** - There are no valid reasons to push directly to remote repositories
- **USE PULL REQUESTS** - All changes must go through the PR workflow for review
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., bash, mcp, tmux, git)
- Always assume latest Amazon Q version is installed
- Follow Versioning Mindset: iterate rather than reinvent
- Scalpel for edits instead of machete
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Pull Request based workflow (GitHub)
- Tracer bullet / vibe coding development style

## Debugging Amazon Q CLI
- For definitive answers refer to the amazon-q-developer-cli source code at https://github.com/aws/amazon-q-developer-cli

## Building from Source
- Building from source allows us to add logging, debug issues, and make contributions
- When working with these tools, cd into their respective directories to make changes and commit them
- This approach gives us more control and visibility into how these tools function
- Leverage the ability to modify the source code to improve our understanding and usage of these tools

## Common Errors to Avoid
- Don't thank self when closing your own PRs
