# MCP Servers

Wrapper scripts and configuration for MCP clients (Claude Code, Amazon Q, Cursor, etc).

## Available Servers

| Server | When to Use This | Auth | Source | Claude Code |
|--------|------------------|------|--------|-------------|
| Playwright | **Use this to automate browser interactions** - web scraping, testing, taking screenshots, filling forms. Your tool for any browser-based task. | None | [Official NPM](https://www.npmjs.com/package/@playwright/mcp) | ✅ Enabled |
| Brave Search | **Use this to search the web** (only in non-Claude clients) - finding documentation, current events, external resources. | API key | [Official NPM](https://www.npmjs.com/package/@modelcontextprotocol/server-brave-search) | ❌ Disabled* |

**Note**: Git and GitHub operations now use direct CLI tools via Bash for better reliability and performance (see issue #1215).

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
  "enabledMcpjsonServers": ["playwright"]
}
```

## Debugging MCP Servers

When an MCP server shows as "failed" in Claude Code:

For browser mode selection and stability in AI CLI sessions, use:
- `knowledge/procedures/playwright-headed-vs-headless.md`
- `docs/playwright-headed-headless-cheatsheet.md`

### 1. Quick Health Check
```bash
# Check individual server logs if needed
check-mcp-logs          # View errors and tool calls
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
| Playwright "failed" | npm/npx not available | Install Node.js: `brew install node` |
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
# Test MCP handshake for npm-based servers
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "smoke-test", "version": "1.0.0"}}}' | npx @playwright/mcp
```
