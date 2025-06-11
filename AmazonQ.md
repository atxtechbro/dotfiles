# Repository-Specific Amazon Q Context

## Dotfiles Philosophy
- See README.md for our core principles: The Spilled Coffee Principle, The Snowball Method, and The Versioning Mindset

## GitHub Workflow
- Pull Request based workflow (GitHub)
- Repository: atxtechbro/dotfiles
- Username: atxtechbro

## Automation Principles
- Avoid manual, one-off commands. Instead, commit to setup scripts and run them (automation mindset)
- Always create setup scripts for file operations instead of ad-hoc terminal commands
- Use installation scripts that detect and create required directories
- Prefer symlinks managed by setup scripts over manual file copying
- Document all dependencies and installation steps in README files

## Script Design
- Scripts should be idempotent - safe to run multiple times
- Detect and handle errors gracefully
- Provide clear feedback on what's happening
- Use environment detection where possible
- Follow the principle of least surprise

## Testing
- Test scripts in clean environments
- Verify all dependencies are properly handled
- Check for platform-specific issues
- Ensure proper error messages for common failures

## Building from Source
- Building from source allows us to add logging, debug issues, and make contributions
- When working with these tools, cd into their respective directories to make changes and commit them
- This approach gives us more control and visibility into how these tools function
- Leverage the ability to modify the source code to improve our understanding and usage of these tools
