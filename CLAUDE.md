# AI Provider Context

This repository uses a unified knowledge base for all AI providers.

## Global Context
See `knowledge/` directory for principles and procedures that apply across all projects.

## Repository-Specific Context
- Repository: atxtechbro/dotfiles
- Primary workflow: GitHub Pull Requests
- See README.md for repository-specific principles

## For AI Providers
- **Amazon Q**: Uses symlinked `~/.amazonq/rules/` → `knowledge/`
- **Claude Code**: Uses generated `CLAUDE.local.md` files
- **Others**: See `docs/ai-provider-agnostic-context.md` for integration patterns

All providers should reference the same `knowledge/` directory as the single source of truth.