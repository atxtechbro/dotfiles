## We're following a tracer bullet development approach, therefore:

## Dotfiles Philosophy
- See README.md for our core principles: The Spilled Coffee Principle, The Snowball Method, and The Versioning Mindset
- Avoid manual, one-off commands. Instead, commit to setup scripts and run them (automation mindset)
- Always create setup scripts for file operations instead of ad-hoc terminal commands
- Use installation scripts that detect and create required directories
- Prefer symlinks managed by setup scripts over manual file copying
- Document all dependencies and installation steps in README files

## Tips

### Git Workflow
- Commit early and often with meaningful changes
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., bash, mcp, tmux, git)
- Always assume latest Amazon Q version is installed
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Pull Request based workflow (GitHub)
- Tracer bullet / vibe coding development style
- Keep changes small and frequent – Encourage developers to commit small, incremental changes or features
- Use short-lived branches for complex tasks – For larger or more complex tasks, use short-lived branches
- Maintain a robust test suite – A comprehensive, well-maintained test suite is crucial
- Do, don't explain – Execute tasks directly rather than describing how to do them

## Debugging Amazon Q CLI
- For definitive answers refer to the amazon-q-developer-cli source code at https://github.com/aws/amazon-q-developer-cli

## Building from Source
- Building from source allows us to add logging, debug issues, and make contributions
- When working with these tools, cd into their respective directories to make changes and commit them
- This approach gives us more control and visibility into how these tools function
- Leverage the ability to modify the source code to improve our understanding and usage of these tools

## Common Errors to Avoid
- Don't thank self when closing your own PRs
