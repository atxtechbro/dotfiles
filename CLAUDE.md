# AI Provider Context

This repository uses a unified knowledge base for all AI providers.

## Global Context
See `knowledge/` directory for principles and procedures that apply across all projects.

## Repository-Specific Context
- Repository: atxtechbro/dotfiles
- Primary workflow: GitHub Pull Requests
- See README.md for repository-specific principles

## Critical: Claude Self-Invocation
When invoking claude commands from within Claude Code:
- **ALWAYS use**: `claude -p <command>` 
- **NEVER use**: `claude <command>`

This prevents nested interactive session conflicts since we're already in an interactive Claude session and our `claude` alias includes `--mcp-config` and `--add-dir` flags.

Examples:
```bash
# Testing functionality
claude -p "test the new MCP server"

# Checking configuration
claude -p config get theme

# Running diagnostics
claude -p doctor

# Setting up tokens
claude -p setup-token
```

## For AI Providers
- **Amazon Q**: Uses symlinked `~/.amazonq/rules/` → `knowledge/`
- **Claude Code**: Uses generated `CLAUDE.local.md` files
- **Others**: See `docs/ai-provider-agnostic-context.md` for integration patterns

All providers should reference the same `knowledge/` directory as the single source of truth.