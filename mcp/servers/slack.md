# Slack MCP Server

The Slack MCP server provides AI assistants with access to Slack workspaces, channels, messages, and other Slack data.

## Installation

The Slack MCP server is installed automatically via NPX when configured in your MCP configuration file.

## Configuration

Basic configuration:

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-slack"
      ],
      "env": {
        "SLACK_TOKEN": "${COMPANY_SLACK_TOKEN}"
      }
    }
  }
}
```

## Authentication

The Slack MCP server requires a Slack API token to access your workspace. You'll need to:

1. Create a Slack app at https://api.slack.com/apps
2. Add the necessary permissions (channels:history, channels:read, users:read, etc.)
3. Install the app to your workspace
4. Get the OAuth token
5. Set the token in your environment:
   ```bash
   export COMPANY_SLACK_TOKEN="xoxb-your-token-here"
   ```

You can add this to your `~/.bash_secrets` file for persistence.

## Capabilities

With the Slack MCP server, AI assistants can:

- Access channel information and history
- Search for messages
- Get user information
- Access workspace data
- Analyze conversation context
- And more Slack-related functionality

## Troubleshooting

If you encounter issues with the Slack MCP server:

1. Verify your Slack token is valid and has the necessary permissions
2. Check if the server is running: `ps aux | grep server-slack`
3. Look for error messages in the AI assistant's output
4. Ensure your Slack workspace is accessible from your current network

## Additional Resources

- [Slack MCP Server Repository](https://github.com/modelcontextprotocol/servers/tree/main/src/slack)
- [Slack API Documentation](https://api.slack.com/docs)
- [Model Context Protocol](https://modelcontextprotocol.github.io/)
