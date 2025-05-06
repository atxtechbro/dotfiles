# GitHub MCP Server

The GitHub MCP server provides AI assistants with access to GitHub repositories, issues, pull requests, and other GitHub data.

## Installation

The GitHub MCP server is installed automatically via NPX when configured in your MCP configuration file.

## Configuration

Basic configuration:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@github/github-mcp-server"
      ]
    }
  }
}
```

## Authentication

The GitHub MCP server uses your local GitHub authentication. Make sure you're authenticated with GitHub CLI:

```bash
gh auth login
```

## Capabilities

With the GitHub MCP server, AI assistants can:

- Access repository information
- View and create issues
- View and create pull requests
- Access file contents from repositories
- And more

## Troubleshooting

If you encounter issues with the GitHub MCP server:

1. Verify your GitHub CLI authentication is working: `gh auth status`
2. Check if the server is running: `ps aux | grep github-mcp-server`
3. Look for error messages in the AI assistant's output

## Additional Resources

- [GitHub MCP Server Documentation](https://github.com/github/github-mcp-server)
- [Model Context Protocol](https://modelcontextprotocol.github.io/)
