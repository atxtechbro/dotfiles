# AI Provider Agnostic Context System

This document explains how the dotfiles repository provides consistent global context across different AI coding assistants.

## Overview

The dotfiles repository maintains a single source of truth for development principles and procedures in the `knowledge/` directory, then automatically configures different AI providers to use this shared context.

## Supported AI Providers

### Amazon Q Developer CLI

**Configuration Location**: `~/.aws/amazonq/global_context.json`
**Rules Location**: `~/.amazonq/rules/` (symlinked to `knowledge/`)
**Setup Script**: `utils/setup-amazonq-rules.sh`

Amazon Q uses:
- Global context configuration file that specifies paths to include
- Symlinked rules directory pointing to the knowledge base
- Automatic discovery of `.md` files in the rules directory

### Claude Code

**Configuration Location**: Command-line alias in `.bash_aliases.d/claude-mcp.sh`
**Setup Method**: `--add-dir` flag in alias

Claude Code uses:
- Native directory discovery via `--add-dir "$DOT_DEN/knowledge"` flag
- Real-time access to knowledge files (no compilation needed)
- Alias ensures knowledge directory is always included in context

## Architecture

```
~/ppv/pillars/dotfiles/
├── knowledge/                    # Single source of truth
│   ├── principles/              # Core development principles
│   └── procedures/              # Actionable processes
├── utils/
│   └── setup-amazonq-rules.sh  # Amazon Q configuration
├── .bash_aliases.d/
│   └── claude-mcp.sh          # Claude alias with --add-dir
└── setup.sh                    # Sources aliases and runs setup scripts

# Generated configurations:
~/.amazonq/rules/               # Symlink to knowledge/
~/.aws/amazonq/global_context.json
# Claude: No generated files needed - uses --add-dir flag
```

## Key Design Decisions

### Single Source of Truth
All principles and procedures are maintained in `knowledge/` directory. This prevents drift between different AI providers and ensures consistency.

### Provider-Specific Adaptation
Each AI provider has different context mechanisms:
- **Amazon Q**: Uses symlinks for file discovery
- **Claude Code**: Uses --add-dir flag for directory inclusion

### Automated Setup
Both systems are configured automatically by `setup.sh`, following the Spilled Coffee Principle.

### Real-time Updates
Both providers now support real-time updates:
- **Amazon Q**: Symlinks mean changes to knowledge/ are immediately available
- **Claude Code**: --add-dir flag means changes to knowledge/ are immediately available

## Usage

### Initial Setup
```bash
source setup.sh
```

This automatically configures both Amazon Q and Claude Code.

### Updating Context

Changes to `knowledge/` are immediately available for both providers:
- **Amazon Q**: Via symlink
- **Claude Code**: Via --add-dir flag

No regeneration or manual updates needed!

### Adding New Principles or Procedures

1. Add new `.md` files to `knowledge/principles/` or `knowledge/procedures/`
2. For Amazon Q: Changes are immediately available
3. For Claude Code: Run `utils/setup-claude-rules.py` to regenerate context

## File Locations

### Amazon Q
- Global config: `~/.aws/amazonq/global_context.json`
- Rules directory: `~/.amazonq/rules/` → `~/ppv/pillars/dotfiles/knowledge/`

### Claude Code
- Alias configuration: `~/.bash_aliases.d/claude-mcp.sh`
- Knowledge accessed via: `--add-dir` flag in alias

## Troubleshooting

### Amazon Q Not Loading Context
1. Check if `~/.amazonq/rules/` is properly symlinked
2. Verify `~/.aws/amazonq/global_context.json` exists
3. Re-run `utils/setup-amazonq-rules.sh`

### Claude Code Not Loading Context
1. Check if alias is loaded: `alias claude`
2. Verify knowledge directory exists: `ls -la $DOT_DEN/knowledge`
3. Re-source aliases: `source ~/.bashrc`

### Context Updates
Changes to `knowledge/` files are automatically available for both providers - no action needed!

## Future Providers

To add support for a new AI provider:

1. Create `utils/setup-<provider>-rules.py`
2. Implement provider-specific context mechanism
3. Add call to `setup.sh`
4. Update this documentation

The goal is to maintain the single source of truth in `knowledge/` while adapting to each provider's specific context system.
