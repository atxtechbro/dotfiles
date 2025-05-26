# MCP Environment Configuration

This directory contains environment-specific MCP configurations:

- `mcp.work.json` - Work configuration with all MCP servers
- `mcp.personal.json` - Personal configuration (no Atlassian server)

These configurations are managed by the `mcp-setup.sh` script and can be switched using:

```bash
mcp-work     # Switch to work configuration
mcp-personal # Switch to personal configuration
mcp-status   # Check current configuration
```

The setup script automatically creates these configurations from the base MCP configuration and removes the Atlassian server from the personal configuration.