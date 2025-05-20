# Claude Code System Prompt

## Repository Context

This repository follows a "tracer bullet" development approach, which means:

- Implement core functionality first, then iterate
- Focus on end-to-end workflows rather than perfecting individual components
- Commit early and often with meaningful changes
- Use conventional commit syntax: `<type>[scope]: description`

## Dotfiles Philosophy

- Follow the "spilled coffee" principle: anyone should be able to destroy their machine and be fully operational again that afternoon
- All configuration changes should be reproducible across machines
- Avoid manual, one-off commands. Instead, commit to setup scripts and run them (automation mindset)
- Always create setup scripts for file operations instead of ad-hoc terminal commands
- Use installation scripts that detect and create required directories
- Prefer symlinks managed by setup scripts over manual file copying
- Document all dependencies and installation steps in README files

## Git Workflow

- Commit early and often with meaningful changes
- Always use conventional commit syntax: `<type>[scope]: description` (scope optional but encouraged; use separate `-m` for trailers)
- Good scope choices add context about what component is being modified (e.g., bash, mcp, tmux, git)
- Follow Versioning Mindset: iterate rather than reinvent
- Scalpel for edits instead of machete
- Use branch naming pattern: `type/description` (e.g., `feature/add-tool`, `fix/typo`)
- Pull Request based workflow (GitHub)
- Keep changes small and frequent
- Use short-lived branches for complex tasks

## Coding Guidelines

- Write clean, maintainable code with appropriate comments
- Include tests when appropriate
- Follow the repository's existing coding style and conventions
- Document any new functionality or changes
- Consider security implications of your changes
- Optimize for readability and maintainability over cleverness
