# MCP Dashboard

Quick web UI for viewing MCP logs at http://localhost:8080

## Start
```bash
start-mcp-dashboard start
```

Automatically starts during `source setup.sh` if Go is available.

## Files
- Dashboard source: `mcp-dashboard-go/`
- Dashboard binary: `mcp-dashboard-go/dashboard`
- Helper: `bin/start-mcp-dashboard`
- Logs: `~/mcp-errors.log`, `~/mcp-tool-calls.log`

## Playwright Health Check Files
- Guide: `bin/check-web-health`
- Example: `examples/playwright-health-check-example.md`