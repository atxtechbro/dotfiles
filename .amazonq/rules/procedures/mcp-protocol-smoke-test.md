# MCP Protocol Smoke Test

→ [MCP README - Protocol Testing](~/ppv/pillars/dotfiles/mcp/README.md#protocol-testing)

**Tracer bullets example**: Protocol-level testing provides immediate feedback on actual MCP functionality vs CLI wrapper testing. Automated, no manual restart needed, tight feedback loop.

```bash
(echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", ...}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | .venv/bin/python -m mcp_server_git -r .
```

Use after MCP server modifications. Commit trailer: `Principle: tracer-bullets`
