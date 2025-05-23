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

### Git Workflow
- Commit early and often with meaningful changes
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., bash, mcp, tmux, git)
- Always assume latest Amazon Q version is installed
- Follow Versioning Mindset: iterate rather than reinvent
- Scalpel for edits instead of machete
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Pull Request based workflow (GitHub)
- Tracer bullet / vibe coding development style
- Keep changes small and frequent – Encourage developers to commit small, incremental changes or features. This reduces the risk of merge conflicts and makes it easier to identify and fix issues quickly
- Use short-lived branches for complex tasks – For larger or more complex tasks, use short-lived branches (also known as task branches) to work on the changes. However, make sure to keep the branch lifespan short, typically less than a day. Merge the changes back into the develop branch (Gitflow) or main branch (Trunk or GitHub Flow) as soon as possible. Smaller and more frequent merges and reviews are easier for a team to consume and process than one large merge request
- Maintain a robust test suite – A comprehensive, well-maintained test suite is crucial for detecting issues early and verifying that the code base remains stable. Invest in test automation and prioritize fixing any failing tests
- Proactively suggest git hook opportunities – During workflows, identify and suggest when a git hook implementation would be valuable. Since the driver is actively learning about git hooks, highlight potential use cases with high reward-to-effort ratios. Store these hooks in the dotfiles repository to maintain consistency across environments

## File Operations Approach
Use fs_read instead of GitHub MCP functions (like get_file_contents) for reading files
Use fs_write instead of GitHub MCP functions (like create_or_update_file) for file edits
Use git push instead of github mcp equivalent to push contents
This makes it easier to see diffs and understand changes being made
Assume we're working with the repository checked out locally (atxtechbro/dotfiles on GitHub)

## Debugging Amazon Q CLI
- For definitive answers refer to the amazon-q-developer-cli source code at https://github.com/aws/amazon-q-developer-cli

## Building from Source
- Building from source allows us to add logging, debug issues, and make contributions
- When working with these tools, cd into their respective directories to make changes and commit them
- This approach gives us more control and visibility into how these tools function
- Leverage the ability to modify the source code to improve our understanding and usage of these tools

## Common Errors to Avoid
- Don't thank self when closing your own PRs
