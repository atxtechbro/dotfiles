# Claude Code Settings Configuration

This document describes how we manage Claude Code settings in our dotfiles repository, ensuring all configurations survive the "spilled coffee test."

## Overview

We use a configuration-as-code approach to manage Claude Code settings, storing them in version control and applying them automatically during setup.

These settings were discovered by running `claude config list --global` and capturing the current configuration to prevent environment drift.

## Current Implementation

### Settings File
All Claude Code settings are defined in `.claude/settings/claude-code-defaults.json`. This file is the single source of truth for our configuration.

### Application Script
The `utils/configure-claude-code-settings.sh` script:
- Reads settings from the JSON file
- Applies each setting using `claude config set --global`
- Shows selected settings after configuration
- Provides platform-specific setup notes

### Integration
The configuration script is called automatically:
- During initial setup via `setup.sh`
- When installing/updating Claude Code via `install-claude-code.sh`

## Available Settings

### Global Settings (via `claude config`)
See `.claude/settings/claude-code-defaults.json` for the current configuration. The settings file is the source of truth and includes:

- **Visual**: theme, editor mode
- **Behavior**: auto-updates, verbose output, diff tool
- **Notifications**: preferred channel, idle thresholds  
- **Performance**: parallel task execution
- **Features**: todo list, auto-compact, IDE connections

Each setting in the JSON file is automatically applied by the configuration script.

### Project Settings (direct file read)
See `.claude/settings.local.json` for project-level settings including:

- **Permissions**: allowed and denied tool usage patterns (see `knowledge/procedures/claude-code-permissions.md` for the philosophy behind these permissions and how they align with OSE principle)
- **Environment Variables**: timeout limits, token limits, cost warnings
- **MCP Servers**: enabled Model Context Protocol servers

Environment variables configured:
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS`: 8192 - Maximum tokens in Claude responses
- `BASH_DEFAULT_TIMEOUT_MS`: 120000 - Default bash command timeout (2 min)
- `BASH_MAX_TIMEOUT_MS`: 600000 - Maximum bash timeout (10 min)
- `BASH_MAX_OUTPUT_LENGTH`: 50000 - Max characters before truncation
- `DISABLE_COST_WARNINGS`: 1 - Suppress cost warning messages
- `MCP_TIMEOUT`: 30000 - MCP server startup timeout
- `MCP_TOOL_TIMEOUT`: 60000 - MCP tool execution timeout
- `MAX_MCP_OUTPUT_TOKENS`: 25000 - Maximum tokens in MCP responses

## Adding New Settings

1. Add the setting to `.claude/settings/claude-code-defaults.json`
2. The configure script will automatically apply it
3. Update this documentation

## Future Migration

We're tracking the migration to the new `settings.json` format in issue #577. This will provide:
- Better hierarchical settings management
- Native environment variable support
- Direct file-based configuration
- Enterprise policy support

## Testing

To verify settings are applied correctly:
```bash
# Apply settings
./utils/configure-claude-code-settings.sh

# Check all settings
claude config list --global

# Check specific setting
claude config get --global theme
```

## Platform Notes

### macOS
For terminal bell notifications in iTerm2:
1. System Settings → Notifications → iTerm2 → Enable
2. iTerm2 Preferences → Profiles → Terminal → Enable bell

### Linux
Terminal bell should work by default in most terminal emulators.

## Related
- Issue #564: Claude Code Settings Configuration-as-Code
- Issue #577: Migrate to settings.json Format
- Issue #579: Add Environment Variables (implemented)
- Issue #580: Configure Additional settings.json Options
- Principle: systems-stewardship