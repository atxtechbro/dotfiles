# Environment-Aware MCP Configuration

This feature adds environment-based toggling for MCP servers, allowing you to automatically disable specific MCP servers based on your environment (work vs. personal).

## How It Works

1. Environment detection based on hostname
2. Automatic disabling of specific MCP servers on personal computers
3. Simple wrapper script that modifies the MCP configuration on the fly
4. No changes to your existing MCP configuration files

## Setup

1. Add the `shell/mcp-env.sh` content to your `.bashrc` or `.zshrc`
2. Make sure the `bin/mcp-wrapper.sh` script is executable
3. Use the `q` command as usual - the environment detection happens automatically

## Configuration

You can control which MCP servers are disabled by setting environment variables:

```bash
# Disable Atlassian MCP server
export MCP_DISABLE_ATLASSIAN=true

# Disable Slack MCP server
export MCP_DISABLE_SLACK=true
```

These are automatically set based on hostname detection, but you can override them manually if needed.