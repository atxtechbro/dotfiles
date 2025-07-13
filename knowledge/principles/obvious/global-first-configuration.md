# Global-First Configuration

Configurations in dotfiles should default to global application unless explicitly marked otherwise.

## The Principle

**Default to global**: When adding configurations to dotfiles, make them globally accessible across the system, not just locally within the repository.

**Bias toward global over local**: When implementing features, choose global configuration patterns over local ones. This aligns with the fundamental purpose of dotfiles repositories.

**Explicit exceptions**: If a configuration must be local-only, document why and include a plan to make it global in the future.

## Why This Matters

- **User expectation alignment**: When someone adds configuration to a dotfiles repository, they naturally expect it to apply globally across their system
- **Supports the Spilled Coffee Principle**: Everything should be reproducible globally, not just in the local repository context
- **Reduces manual configuration**: Global configurations eliminate the need to manually set up each new machine
- **Eliminates confusion**: Clear distinction between what's active where prevents configuration drift

## Implementation Patterns

- **Aliases and symlinks**: Use these to make local configurations globally accessible
- **Tool-specific global config locations**: Leverage each tool's intended global configuration paths
- **Environment variables**: Export configuration through shell environments that persist across sessions

## Examples

**Good**: 
- Claude Code settings symlinked to `~/.claude/settings.json`
- MCP configurations accessible from any directory via symlinks
- Git configurations applied system-wide

**Needs improvement**:
- Configurations that only work when running commands from the dotfiles directory
- Tool settings that require manual copying to global locations
- Environment variables that only exist in the dotfiles context

## Exception Handling

When global configuration isn't possible:
1. Document the limitation clearly
2. Explain the technical constraint preventing global application
3. Include a plan or issue link for future global enablement
4. Mark clearly as "local-only" to set proper expectations

## Relationship to Other Principles

**Systems Stewardship**: This principle creates consistent, maintainable patterns for configuration management.

**Subtraction Creates Value**: Global configurations eliminate the cognitive overhead of remembering which settings apply where.

**Versioning Mindset**: Configurations should evolve toward global applicability over time, not remain permanently local.