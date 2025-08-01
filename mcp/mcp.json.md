# MCP Configuration Explained

This document explains the `mcp.json` configuration file that powers MCP servers across all clients.

## File Location
- **Path**: `/home/linuxmint-lp/ppv/pillars/dotfiles/mcp/mcp.json`
- **Purpose**: Single source of truth for MCP server configuration
- **Used by**: Claude Code, Amazon Q, Cursor, and other MCP clients

## Structure Overview

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

## Server Configuration Fields

### `command`
The executable to run. This is typically:
- A wrapper script (e.g., `./mcp/git-mcp-wrapper.sh`)
- A Node.js command (e.g., `node`)
- A Python command (e.g., `python`)

### `args`
Command-line arguments passed to the executable:
- For wrapper scripts: Usually empty `[]`
- For Node.js: Path to the server script
- For Python: `-m module_name` and additional args

### `env` (optional)
Environment variables specific to this server:
- API keys (e.g., `BRAVE_API_KEY`)
- Configuration paths
- Feature flags

## Current Servers

### Git Server
```json
"git": {
  "command": "/home/linuxmint-lp/ppv/pillars/dotfiles/mcp/git-mcp-wrapper.sh",
  "args": []
}
```
- **Purpose**: All git operations (status, diff, commit, branch, etc.)
- **Wrapper**: Activates virtual environment and runs Python server
- **No auth required**: Works with local repositories

### GitHub Server
```json
"github": {
  "command": "/home/linuxmint-lp/ppv/pillars/dotfiles/mcp/github-mcp-wrapper.sh",
  "args": []
}
```
- **Purpose**: GitHub API operations (issues, PRs, search)
- **Auth**: Uses `gh auth token` (must be logged in)
- **Wrapper**: Ensures GitHub CLI is authenticated

### Playwright Server
```json
"playwright": {
  "command": "/home/linuxmint-lp/ppv/pillars/dotfiles/mcp/playwright-mcp-wrapper.sh",
  "args": []
}
```
- **Purpose**: Browser automation and web scraping
- **Features**: Screenshots, form filling, navigation
- **No auth required**: Works out of the box

### Brave Search Server
```json
"brave-search": {
  "command": "node",
  "args": ["/path/to/server/index.js"],
  "env": {
    "BRAVE_API_KEY": "your-api-key"
  }
}
```
- **Purpose**: Web search capabilities
- **Auth**: Requires Brave Search API key
- **Note**: Disabled in Claude Code (has native WebSearch)

## Client-Specific Configuration

### Claude Code
Uses `.claude/settings.json` to selectively enable servers:
```json
{
  "enableAllProjectMcpServers": false,
  "enabledMcpjsonServers": ["git", "github", "playwright"]
}
```

### Amazon Q
Discovers `mcp.json` automatically in project root.

### Other Clients
Most MCP clients can be configured to read from `mcp.json`.

## Adding New Servers

1. Create wrapper script: `mcp/<name>-mcp-wrapper.sh`
2. Add server config to `mcp.json`
3. Update documentation in `mcp/README.md`
4. Test with `check-mcp-health.sh`
5. Configure client-specific settings if needed

## Troubleshooting

If a server shows as "failed":
1. Check wrapper script exists and is executable
2. Verify dependencies are installed
3. Check authentication (GitHub, API keys)
4. Run `check-mcp-health.sh` for diagnostics
5. Test manually with protocol commands (see mcp/README.md)

## Best Practices

- Keep wrapper scripts simple and focused
- Use absolute paths in configurations
- Document any required environment variables
- Test changes with multiple MCP clients
- Maintain backwards compatibility