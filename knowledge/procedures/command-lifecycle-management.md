# Command Lifecycle Management

Prevents orphaned Claude commands when renaming/iterating. Principles: systems-stewardship, subtraction-creates-value.

## Tools

```bash
utils/sync-claude-commands.sh --check   # Detect orphaned/missing
utils/sync-claude-commands.sh --clean   # Remove orphaned
utils/generate-commands.sh              # Auto-cleans + generates
```

## Lifecycle

1. **Create**: Add template to `.claude/command-templates/*.md`
2. **Generate**: Run `utils/generate-commands.sh` → outputs to `~/.claude/commands/`
3. **Rename**: Rename template file + regenerate (auto-removes old)
4. **Delete**: Remove template + regenerate (auto-cleans orphaned)

## Validation Layers

- **Pre-commit hook**: `.githooks/pre-commit` (auto-configured by setup.sh)
- **CI/CD**: `validate-dotfiles.yml` runs sync check
- **Manual**: `utils/sync-claude-commands.sh --check`

## Quick Fixes

```bash
# CI failing on sync?
utils/generate-commands.sh
git add -A && git commit --amend

# Orphaned commands persist?
utils/sync-claude-commands.sh --clean
```

## Architecture

```
.claude/command-templates/*.md  → generate-commands.sh → ~/.claude/commands/*.md
                                   ↓
                            sync-claude-commands.sh (cleanup)