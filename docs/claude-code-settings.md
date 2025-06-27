# Claude Code Settings Configuration

This document describes how we manage Claude Code settings in our dotfiles repository, ensuring all configurations survive the "spilled coffee test."

## Overview

We use a configuration-as-code approach to manage Claude Code settings, storing them in version control and applying them automatically during setup.

## Current Implementation

### Settings File
All Claude Code settings are defined in `.claude/settings/claude-code-defaults.json`:

```json
{
  "theme": "dark-daltonized",
  "editorMode": "normal",
  "autoUpdates": true,
  "verbose": false,
  "preferredNotifChannel": "terminal_bell",
  "diffTool": "auto",
  "parallelTasksCount": 1,
  "todoFeatureEnabled": true,
  "messageIdleNotifThresholdMs": 60000,
  "autoConnectIde": false,
  "autoCompactEnabled": true
}
```

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

| Setting | Description | Default | Our Value |
|---------|-------------|---------|-----------|
| `theme` | Color theme | `dark` | `dark-daltonized` |
| `editorMode` | Editor mode | `normal` | `normal` |
| `autoUpdates` | Enable automatic updates | `true` | `true` |
| `verbose` | Show full command outputs | `false` | `false` |
| `preferredNotifChannel` | Notification channel | `iterm2` | `terminal_bell` |
| `diffTool` | Diff tool preference | `auto` | `auto` |
| `parallelTasksCount` | Parallel task execution | `1` | `1` |
| `todoFeatureEnabled` | Enable todo list feature | `true` | `true` |
| `messageIdleNotifThresholdMs` | Idle notification delay | `60000` | `60000` |
| `autoConnectIde` | Auto-connect to IDE | `false` | `false` |
| `autoCompactEnabled` | Auto-compact messages | `true` | `true` |

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
- Principle: systems-stewardship