# Claude Code Enterprise Policy Configuration

This document describes how Claude Code enterprise-level permissions are configured in the dotfiles repository to automatically approve GitHub requests without user prompts.

## Overview

Claude Code enterprise permissions are configured through the existing global settings symlink mechanism, following the **OSE (Outside and Slightly Elevated)** principle to eliminate permission prompt interruptions during agent orchestration workflows.

## Implementation Approach

### Versioning Mindset Applied

Rather than creating a separate enterprise policy file, we **extended the existing** `.claude/settings.json` file following the **Versioning Mindset** principle:

- **Iteration over reinvention**: Enhanced existing configuration instead of creating new files
- **Symlink-based approach**: Leveraged existing dotfiles symlink pattern for enterprise-level distribution
- **Single source of truth**: All Claude Code permissions managed in one location

### Configuration Location

**File**: `.claude/settings.json` (in dotfiles repository)  
**Symlink Target**: `~/.claude/settings.json` (global user settings)  
**Precedence**: Enterprise-level (applies to all Claude Code usage)

## GitHub Domain Auto-Approval

The following domains are automatically approved for WebFetch operations:

```json
"permissions": {
  "allow": [
    // ... other permissions ...
    "WebFetch(domain:docs.anthropic.com)",
    "WebFetch(domain:github.com)",
    "WebFetch(domain:api.github.com)", 
    "WebFetch(domain:raw.githubusercontent.com)",
    "WebFetch(domain:githubusercontent.com)"
  ]
}
```

## How It Works

### Automatic Configuration

1. **Setup Integration**: `setup.sh` creates symlink `~/.claude/settings.json` → `$DOT_DEN/.claude/settings.json`
2. **Global Application**: Settings apply system-wide for all Claude Code usage
3. **Persistent**: Survives Claude Code updates since settings are stored in dotfiles
4. **Cross-Platform**: Works on both macOS and Linux through symlink mechanism

### Enterprise-Level Benefits

- **No Permission Prompts**: GitHub requests automatically approved
- **Workflow Continuity**: Maintains OSE perspective without interruptions
- **Team Consistency**: Same configuration across all team members using dotfiles
- **Version Controlled**: Enterprise policy changes tracked in git history

## Testing the Configuration

### Verification Steps

1. **Check Settings Symlink**:
   ```bash
   ls -la ~/.claude/settings.json
   # Should show: ~/.claude/settings.json -> /path/to/dotfiles/.claude/settings.json
   ```

2. **Test GitHub Request**:
   - Attempt to fetch GitHub content in Claude Code
   - Should NOT prompt for permission
   - Should automatically allow the request

3. **Compare Behavior**:
   - **With dotfiles**: No permission prompts for GitHub
   - **Without dotfiles**: Manual approval required for each domain

## Related Configurations

### Existing MCP GitHub Tools

The settings.json already includes comprehensive GitHub MCP tool permissions:

```json
"permissions": {
  "allow": [
    "mcp__github-read__*",
    "mcp__github-write__*",
    // ... specific GitHub MCP tools ...
  ]
}
```

### Environment Variables

GitHub-related timeouts and limits configured via:

```json
"env": {
  "MCP_TIMEOUT": "30000",
  "MCP_TOOL_TIMEOUT": "60000",
  "MAX_MCP_OUTPUT_TOKENS": "25000"
}
```

## Maintenance

### Adding New Domains

To add auto-approval for additional domains:

1. Edit `.claude/settings.json` in dotfiles repository
2. Add new `WebFetch(domain:example.com)` entry to permissions.allow array
3. Commit changes - applies automatically via symlink

### Removing Permissions

To remove auto-approval:

1. Remove the relevant `WebFetch(domain:*)` entries from `.claude/settings.json`
2. Commit changes
3. Permissions revert to manual approval

## Cross-Platform Support

### Linux
- **Path**: `~/.claude/settings.json` → dotfiles symlink
- **Works**: Out of the box with standard symlink support

### macOS  
- **Path**: `~/.claude/settings.json` → dotfiles symlink
- **Works**: Out of the box with standard symlink support

## Principles Applied

- **[OSE (Outside and Slightly Elevated)](../knowledge/principles/ose.md)**: Eliminates permission prompt interruptions that break agent orchestration flow
- **[Versioning Mindset](../knowledge/principles/versioning-mindset.md)**: Extended existing configuration rather than creating new files
- **[Systems Stewardship](../knowledge/principles/systems-stewardship.md)**: Leveraged existing dotfiles symlink patterns for maintainable enterprise configuration
- **[Subtraction Creates Value](../knowledge/principles/subtraction-creates-value.md)**: Removed permission prompt friction without adding complexity

## Related Issues

- **Issue #889**: feat(claude-code): add enterprise policy configuration for permanent GitHub permissions
- **Issue #564**: Claude Code Settings Configuration-as-Code (existing settings.json approach)

## References

- [Mastering Claude Code in 30 Minutes @ 16:29](https://www.youtube.com/live/6eBSHbLKuN0?t=989) - Enterprise policy concept
- [Claude Code Settings Documentation](claude-code-settings.md) - Comprehensive settings guide
- [OSE Principle](../knowledge/principles/ose.md) - Systems-level thinking for AI agent management