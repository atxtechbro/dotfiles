# AI Provider Agnostic Context System

This document explains how the dotfiles repository provides consistent global context across different AI coding assistants.

## Overview

The dotfiles repository maintains a single source of truth for development principles and procedures in the `knowledge/` directory, then automatically configures different AI providers to use this shared context.

## Supported AI Providers

### Amazon Q Developer CLI

**Configuration Location**: `~/.aws/amazonq/global_context.json`
**Rules Location**: `~/.amazonq/rules/` (symlinked to `knowledge/`)
**Setup Script**: `utils/setup-amazonq-rules.py`

Amazon Q uses:
- Global context configuration file that specifies paths to include
- Symlinked rules directory pointing to the knowledge base
- Automatic discovery of `.md` files in the rules directory

### Claude Code

**Configuration Location**: `~/CLAUDE.local.md` and `~/ppv/pillars/dotfiles/CLAUDE.local.md`
**Setup Script**: `utils/setup-claude-rules.py`

Claude Code uses:
- `CLAUDE.local.md` files that contain the full context (personal, not committed)
- Recursive directory traversal to discover these files
- Content is generated from the knowledge base and embedded directly

## Architecture

```
~/ppv/pillars/dotfiles/
├── knowledge/                    # Single source of truth
│   ├── principles/              # Core development principles
│   └── procedures/              # Actionable processes
├── utils/
│   ├── setup-amazonq-rules.py  # Amazon Q configuration
│   └── setup-claude-rules.py   # Claude Code configuration
└── setup.sh                    # Calls both setup scripts

# Generated configurations:
~/.amazonq/rules/               # Symlink to knowledge/
~/.aws/amazonq/global_context.json
~/CLAUDE.local.md              # Generated from knowledge/
```

## Key Design Decisions

### Single Source of Truth
All principles and procedures are maintained in `knowledge/` directory. This prevents drift between different AI providers and ensures consistency.

### Provider-Specific Adaptation
Each AI provider has different context mechanisms:
- **Amazon Q**: Prefers file discovery with symlinks
- **Claude Code**: Uses embedded content in memory files

### Automated Setup
Both systems are configured automatically by `setup.sh`, following the Spilled Coffee Principle.

### Personal vs Shared Context
- **Amazon Q**: Uses symlinks, so changes to knowledge/ are immediately available
- **Claude Code**: Uses generated files that need regeneration when knowledge/ changes

## Usage

### Initial Setup
```bash
source setup.sh
```

This automatically configures both Amazon Q and Claude Code.

### Updating Context

**For Amazon Q**: Changes to `knowledge/` are immediately available (symlinked).

**For Claude Code**: Re-run the setup script to regenerate the context files:
```bash
~/ppv/pillars/dotfiles/utils/setup-claude-rules.py
```

### Adding New Principles or Procedures

1. Add new `.md` files to `knowledge/principles/` or `knowledge/procedures/`
2. For Amazon Q: Changes are immediately available
3. For Claude Code: Run `utils/setup-claude-rules.py` to regenerate context

## File Locations

### Amazon Q
- Global config: `~/.aws/amazonq/global_context.json`
- Rules directory: `~/.amazonq/rules/` → `~/ppv/pillars/dotfiles/knowledge/`

### Claude Code
- Home directory: `~/CLAUDE.local.md` (for all projects)
- Dotfiles repo: `~/ppv/pillars/dotfiles/CLAUDE.local.md` (when working in dotfiles)

## Troubleshooting

### Amazon Q Not Loading Context
1. Check if `~/.amazonq/rules/` is properly symlinked
2. Verify `~/.aws/amazonq/global_context.json` exists
3. Re-run `utils/setup-amazonq-rules.py`

### Claude Code Not Loading Context
1. Check if `~/CLAUDE.local.md` exists
2. Verify you're working in a directory where Claude Code can discover the file
3. Re-run `utils/setup-claude-rules.py`

### Context Out of Sync
If you modify `knowledge/` files:
- Amazon Q: Changes are automatic (symlinked)
- Claude Code: Run `utils/setup-claude-rules.py` to regenerate

## Future Providers

To add support for a new AI provider:

1. Create `utils/setup-<provider>-rules.py`
2. Implement provider-specific context mechanism
3. Add call to `setup.sh`
4. Update this documentation

The goal is to maintain the single source of truth in `knowledge/` while adapting to each provider's specific context system.
