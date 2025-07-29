# MCP Servers

Wrapper scripts and configuration for MCP clients (Claude Code, Amazon Q, Cursor, etc).

## Available Servers

| Server | Description | Auth | Claude Code |
|--------|-------------|------|-------------|
| Git | Repository operations | None | ✅ Enabled |
| GitHub | API integration | `gh auth token` | ✅ Enabled |
| Playwright | Browser automation | None | ✅ Enabled |
| Brave Search | Web search | API key | ❌ Disabled* |

*Claude Code has native WebSearch

## Quick Start

```bash
# Most servers auto-setup during ./setup.sh
# For optional servers:
./setup-brave-search-mcp.sh  # If you need web search in other MCP clients
```

## Configuration

- **All clients**: `mcp/mcp.json` - Single source of truth
- **Claude Code**: `.claude/settings.json` - Selective enabling to avoid duplication

### Selective Enabling (Claude Code)

```json
{
  "enableAllProjectMcpServers": false,
  "enabledMcpjsonServers": ["git", "github-read", "github-write", "playwright"]
}
```

## Troubleshooting

```bash
check-mcp-logs          # View errors and tool calls
check-mcp-logs --tools  # Tool calls only
check-mcp-logs --follow # Real-time logs
```

## Adding New Servers

1. Add to `mcp.json`
2. Create `<name>-mcp-wrapper.sh`
3. Create `setup-<name>-mcp.sh` if needed
4. Update table above

## Protocol Testing

```bash
# Test MCP handshake (not just --help)
(echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "smoke-test", "version": "1.0.0"}}}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | .venv/bin/python -m mcp_server_git -r .
```