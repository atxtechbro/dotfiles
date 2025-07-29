# Claude Code PPV Settings

This document describes the recommended Claude Code settings for working with the PPV (Pillars, Pipelines, Vaults) system.

## Quick Setup

Copy the settings file to your Claude Code configuration:
```bash
cp .claude/settings/claude-code-ppv.json ~/.claude/settings.json
```

## Key Settings Explained

### Authentication
- `forceLoginMethod: "claudeai"` - Ensures you're using your Claude Pro/Pro Max account (unlimited plan) rather than API billing

### Directory Access
- `additionalDirectories` - Grants Claude Code access to all PPV directories:
  - `~/ppv/pillars` - Core knowledge and principles
  - `~/ppv/pipelines` - Workflows and processes
  - `~/ppv/vaults` - Secure storage and archives

### Permissions
The settings include pre-approved permissions for:
- Common development tools (npm, pytest, ruff)
- Git operations via MCP tools
- File system operations
- Web fetching from trusted domains

### Environment Variables
Optimized for extended sessions:
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS: "8192"` - Maximum response length
- `BASH_DEFAULT_TIMEOUT_MS: "120000"` - 2-minute default timeout
- `BASH_MAX_TIMEOUT_MS: "600000"` - 10-minute max timeout
- `MCP_TIMEOUT: "30000"` - MCP server startup timeout
- `MAX_MCP_OUTPUT_TOKENS: "25000"` - Maximum MCP response tokens

## Customization

You can modify the template at `.claude/settings/claude-code-ppv.json` before copying to add:
- Additional allowed/denied commands
- Custom environment variables
- Project-specific MCP servers

## Related
- [Claude Code Settings Documentation](https://docs.anthropic.com/en/docs/claude-code/settings)
- Issue #1015: Configure comprehensive Claude Code settings for PPV workspace

Principle: systems-stewardship