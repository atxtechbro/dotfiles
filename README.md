# Environment-Aware MCP Configuration

This feature adds environment-based toggling for MCP servers, allowing you to automatically disable specific MCP servers based on your environment (work vs. personal).

## How It Works

1. Environment detection based on hostname
2. Automatic disabling of specific MCP servers on personal computers
3. Simple wrapper script that modifies the MCP configuration on the fly
4. No changes to your existing MCP configuration files

## Setup

Simply run the dotfiles setup script:

```bash
source setup.sh
```

This will:
1. Install the MCP wrapper script to your dotfiles/bin directory
2. Make the script executable
3. Add the environment detection logic to your .bashrc
4. Set up the alias to use the wrapper script
5. Install jq if it's not already installed (required for the wrapper)

## Configuration

You can control which MCP servers are disabled by setting environment variables:

```bash
# Disable Atlassian MCP server
export MCP_DISABLE_ATLASSIAN=true

# Disable Slack MCP server
export MCP_DISABLE_SLACK=true
```

These are automatically set based on hostname detection, but you can override them manually if needed.

## Spilled Coffee Principle

This feature follows the "spilled coffee" principle:
- All configuration is handled by the setup script
- No manual steps required after running setup.sh
- Environment detection is automatic based on hostname
- Dependencies are checked and installed if missing
