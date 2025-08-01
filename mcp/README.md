# MCP Servers

Wrapper scripts and configuration for MCP clients (Claude Code, Amazon Q, Cursor, etc).

## Available Servers

| Server | When to Use This | Auth | Source | Claude Code |
|--------|------------------|------|--------|-------------|
| Git | **Use this for all git operations** - commits, branches, diffs, logs, worktrees. This is your primary tool for version control. | None | [mcp-servers fork](servers/git-mcp-server) | ✅ Enabled |
| GitHub | **Use this whenever you need to interact with GitHub** - issues, PRs, searching code, managing repositories. Essential for GitHub workflow automation. | `gh auth token` | [Custom server](servers/github-mcp-server) | ✅ Enabled |
| Playwright | **Use this to automate browser interactions** - web scraping, testing, taking screenshots, filling forms. Your tool for any browser-based task. | None | [Official NPM](https://www.npmjs.com/package/@playwright/mcp) | ✅ Enabled |
| Brave Search | **Use this to search the web** (only in non-Claude clients) - finding documentation, current events, external resources. | API key | [Official NPM](https://www.npmjs.com/package/@modelcontextprotocol/server-brave-search) | ❌ Disabled* |

*Claude Code has native WebSearch

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
  "enabledMcpjsonServers": ["git", "github", "playwright"]
}
```

## Debugging MCP Servers

When an MCP server shows as "failed" in Claude Code:

### 1. Quick Health Check
```bash
check-mcp-health.sh     # Check all servers at once
```

### 2. Manual Diagnostic Steps

1. **Check the wrapper script**
   - Location: `mcp/<server>-mcp-wrapper.sh`
   - Verify it exists and is executable

2. **Check the server directory**
   - Python servers need `.venv/bin/python`
   - Node servers need `node_modules/`
   - Go servers need compiled binary

3. **Run the setup script manually**
   ```bash
   ./mcp/setup-<server>-mcp.sh
   ```
   Watch for error messages

4. **Test the server directly** (if needed)
   - Python: `.venv/bin/python -m <module_name> --help`
   - Node: `npx <package> --help`
   - Go: `./<binary> --help`

### Common Failure Modes

| Issue | Cause | Solution |
|-------|-------|----------|
| Git MCP "failed" | Missing `.venv` | Run `setup-git-mcp.sh` |
| Git MCP "failed" | Missing `pyproject.toml` | File may be missing from repo |
| GitHub MCP "failed" | Not authenticated | Run `gh auth login` |
| GitHub MCP "failed" | Binary not built | Run `setup-github-mcp.sh` |
| Brave Search "failed" | Missing API key | Add `BRAVE_API_KEY` to `~/.bash_secrets` |

### Log Locations

- **MCP errors**: `~/mcp-errors.log` - Server initialization failures
- **Tool calls**: `~/mcp-tool-calls.log` - Individual tool execution logs
- **Claude Code logs**: TBD - Client-side logs location varies

## Troubleshooting

```bash
check-mcp-logs          # View errors and tool calls
check-mcp-logs --tools  # Tool calls only
check-mcp-logs --follow # Real-time logs
```

## Protocol Testing

```bash
# Test MCP handshake (not just --help)
(echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "smoke-test", "version": "1.0.0"}}}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | .venv/bin/python -m mcp_server_git -r .
```