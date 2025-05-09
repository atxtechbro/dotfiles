## We're following a tracer bullet development approach, therefore:

### Commit early and often
Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
Always include blank line at end of files

## Common Errors to Avoid
- Don't thank yourself when closing your own PRs

## GitHub CLI Best Practices
- Always use text files and pipe them to GitHub CLI commands

**Example:**
```bash
echo "Issue description" > tmp.txt && \
gh issue create --title "Title" -F tmp.txt
```
- Use tmp.txt for temporary files (it's already in .gitignore)
- This approach follows Unix philosophy and avoids escape sequence issues
- Keep PR descriptions to 34 lines or less to ensure they display properly in all contexts

## GitHub Issues Best Practices
- Use the same text file approach for GitHub issues
- Keep issue descriptions to 18 lines or less when creating new issues to allow room for future discoveries and context
- Never edit an issue if it would cause the total length to exceed 55 lines - create a new issue instead
- Prefer concise issues with less context over verbose ones
- Treat GitHub issues as discussion points and suggestions, not strict mandates

## Debugging Amazon Q CLI
- Amazon Q CLI does not appear to generate log files in the expected locations (`/tmp/q-logs/` or `~/.amazonq/logs/`)
- Data is stored in `~/.local/share/amazon-q/` (including SQLite database and history)
- Configuration directories exist at `~/.aws/amazonq/` and `~/.config/amazonq/`
- Setting environment variables like `Q_LOG_LEVEL=trace` and `RUST_BACKTRACE=full` doesn't produce visible logs
- For debugging MCP server issues, use `Q_LOG_LEVEL=trace q chat --no-interactive` and try to use tools
- For definitive answers on CLI behavior and MCP connections, refer to the amazon-q-developer-cli source code
  
## Branching Strategy
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Pull Request based workflow (GitHub)
- Tracer bullet / vibe coding development style
- When making discrete changes, always branch from main unless specifically asked otherwise
- Use `git checkout main && git pull && git checkout -b type/description` to ensure clean branches
- For changes to documentation or configuration files like AmazonQ.md, especially prefer branching from main
- This prevents unintended changes from feature branches being included in your PR
- NEVER merge into main or push directly to main branch
- Good scope choices add context about what component is being modified (e.g., bash, nvim, tmux, git)

## MCP Testing Best Practices
- Focus on logging to gather feedback when testing MCP server functionality
- Preferred test command: `Q_LOG_LEVEL=trace q chat --no-interactive`
- Test MCP tools directly with: `Q_LOG_LEVEL=trace q chat --no-interactive "try to use the test_hello tool, this is a test"`
- Test GitHub MCP server with: `bin/test-github-mcp` (uses search_repositories as a smoke test)
- When testing, add "this is a test" at the end of your prompt - don't apologize or wonder why it's not working after it fails, just return to caller ASAP
- While test-mcp-server is built and designed ourselves, github-mcp-server must be built from source using Go (not Docker) in the github-mcp-server directory to function properly
- Always assume latest Amazon Q version is installed
- Follow versioning mindset: edit existing files rather than creating new ones with "-fixed" suffix
- For dotfiles, use setup scripts for symlinks rather than manual linking

## Building from Source
- Source code for both Amazon Q CLI and github-mcp-server is conveniently located and gitignored
- Always prefer to build and use the source version of these tools whenever possible
- Building from source allows us to add logging, debug issues, and make contributions
- When working with these tools, cd into their respective directories to make changes and commit them
- This approach gives us more control and visibility into how these tools function
- Leverage the ability to modify the source code to improve our understanding and usage of these tools
- Apply the same "commit early and often" principles when making changes to source code
- Use conventional commit syntax and atomic commits for source code changes
- NEVER create PRs to forked repositories like amazon-q-developer-cli and github-mcp-server
- Keep all changes to forked repos local only - they are for our understanding and debugging
## Dotfiles Philosophy
- All configuration changes should be reproducible across machines
- Avoid manual, one-off commands like `mkdir -p /path/to/dir && cp /source/file /destination/`
- Always create setup scripts for file operations instead of ad-hoc terminal commands
- Follow the "spilled coffee" principle: anyone should be able to destroy their machine and be fully operational again that afternoon
- Use installation scripts that detect and create required directories
- Prefer symlinks managed by setup scripts over manual file copying
- Document all dependencies and installation steps in README files
