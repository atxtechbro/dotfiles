# AI Provider Context

This repository uses a unified knowledge base for all AI providers.

## Global Context
See `knowledge/` directory for principles and procedures that apply across all projects.

## Repository-Specific Context
- Repository: atxtechbro/dotfiles
- Primary workflow: GitHub Pull Requests
- See README.md for repository-specific principles

## Critical: Non-Interactive Execution Only
See `knowledge/procedures/non-interactive-execution.md` for the fundamental principle.

Key insight: You (Claude) are BY DEFINITION already in an interactive session. You literally CANNOT provide interactive input to any command. This includes `claude` commands which must use `-p` flag.

## For AI Providers
- **Amazon Q**: Uses symlinked `~/.amazonq/rules/` → `knowledge/`
- **Claude Code**: Uses generated `CLAUDE.local.md` files
- **Others**: See `docs/ai-provider-agnostic-context.md` for integration patterns

All providers should reference the same `knowledge/` directory as the single source of truth.