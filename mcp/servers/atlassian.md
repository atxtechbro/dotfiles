# Atlassian MCP Server

The Atlassian MCP server provides AI assistants with access to Atlassian products including Jira, Confluence, and other Atlassian ecosystem tools.

## Installation

The Atlassian MCP server is installed automatically via NPX when configured in your MCP configuration file.

## Configuration

Basic configuration:

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": [
        "-y",
        "@sooperset/mcp-atlassian",
        "--baseUrl",
        "https://your-domain.atlassian.net"
      ]
    }
  }
}
```

## Authentication

The Atlassian MCP server requires authentication to access your Atlassian instance. You'll need to set up an API token:

1. Log in to your Atlassian account
2. Create an API token at https://id.atlassian.com/manage-profile/security/api-tokens
3. Set the following environment variables:
   ```bash
   export ATLASSIAN_BASE_URL="https://your-domain.atlassian.net"
   export ATLASSIAN_USERNAME="your-email@example.com"
   export ATLASSIAN_API_TOKEN="your-api-token"
   ```

You can add these to your `~/.bash_secrets` file for persistence.

## Capabilities

With the Atlassian MCP server, AI assistants can:

- Access Jira issues and projects
- View and create Jira tickets
- Search for issues using JQL
- Access Confluence pages and spaces
- And more Atlassian ecosystem integrations

## Troubleshooting

If you encounter issues with the Atlassian MCP server:

1. Verify your API token is valid and has the necessary permissions
2. Check if the server is running: `ps aux | grep mcp-atlassian`
3. Look for error messages in the AI assistant's output
4. Ensure your Atlassian instance is accessible from your current network

## Additional Resources

- [Atlassian MCP Server Repository](https://github.com/sooperset/mcp-atlassian)
- [Model Context Protocol](https://modelcontextprotocol.github.io/)
