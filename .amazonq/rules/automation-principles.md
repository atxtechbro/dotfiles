# Automation Principles

## Core Principles
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
