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
- When configuring Claude Code via `configure-claude-code.sh`

## Available Settings

### Global Settings (via `claude config`)
See `.claude/settings/claude-code-defaults.json` for the current configuration. The settings file is the source of truth and includes:

- **Visual**: theme, editor mode
- **Behavior**: auto-updates, diff tool (Note: verbose is now set via --verbose flag in claude alias)
- **Notifications**: preferred channel, idle thresholds  
- **Performance**: parallel task execution
- **Features**: todo list, auto-compact, IDE connections

Each setting in the JSON file is automatically applied by the configuration script.

### Project Settings (direct file read)
See `.claude/settings.local.json` for project-level settings including:

- **Permissions**: allowed and denied tool usage patterns
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

## Hooks Configuration

Hooks allow you to execute custom commands in response to Claude Code events. They are configured in `.claude/settings.json` under the `"hooks"` key.

**Official Documentation:**
- [Hooks Reference](https://docs.claude.com/en/docs/claude-code/hooks) - Available events, matcher syntax, and configuration structure
- [Hooks Guide](https://docs.claude.com/en/docs/claude-code/hooks-guide) - Examples and best practices

### Hooks Implemented in This Project

#### Notification Hook (Issue #1414)
Displays Linux desktop notifications when Claude Code is awaiting user input.

**Triggers:**
- When Claude requests tool usage permission
- When the prompt input remains idle for 60+ seconds

**Configuration:**
```json
"Notification": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "notify-send 'Claude Code' 'Awaiting your input'"
      }
    ]
  }
]
```

**Prerequisites:**
- Linux: `libnotify-bin` package (installed via `sudo apt install libnotify-bin`)
- macOS: Native notification system (no additional packages required)

**Note:** For `Notification` hooks, the matcher is an empty string (`""`), not `"*"`, since notification events are not tool-specific.

#### SessionEnd Hook (Issue #1416)
Logs basic session metadata when Claude Code sessions end, establishing foundation for session tracking and analytics.

**Triggers:**
- When a session ends (exit, logout, clear command, or other termination)

**Configuration:**
```json
"SessionEnd": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "mkdir -p ~/.claude/sessions && echo \"$(date -Iseconds) | Session: $(jq -r .session_id) | Transcript: $(jq -r .transcript_path) | Reason: $(jq -r .reason)\" >> ~/.claude/sessions/log.txt"
      }
    ]
  }
]
```

**What it logs:**
- ISO 8601 timestamp
- Session ID
- Transcript file path
- Exit reason (clear/logout/prompt_input_exit/other)

**Log location:** `~/.claude/sessions/log.txt`

**Example output:**
```
2025-10-28T14:23:45-05:00 | Session: abc123 | Transcript: ~/.claude/projects/.../session.jsonl | Reason: clear
```

**Future enhancements:**
- Upgrade to JSONL format for structured queries
- Add transcript archiving
- Build summary generation tools

**Note:** For `SessionEnd` hooks, the matcher is an empty string (`""`), not `"*"`, since session end events are not tool-specific.

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

**Verbose Mode**: On Linux systems where Ctrl+R doesn't work due to terminal raw mode limitations, verbose output is enabled by default via the `--verbose` flag in the claude alias. This ensures full output is always visible without relying on the broken interactive toggle.

## Related
- Issue #564: Claude Code Settings Configuration-as-Code
- Issue #577: Migrate to settings.json Format
- Issue #579: Add Environment Variables (implemented)
- Issue #580: Configure Additional settings.json Options
- Issue #1091: Change verbose mode from imperative to --verbose flag
- Principle: systems-stewardship