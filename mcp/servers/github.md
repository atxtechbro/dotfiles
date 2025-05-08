# GitHub MCP Server

The GitHub MCP server provides AI assistants with access to GitHub repositories, issues, pull requests, and other GitHub data.

## Installation

The GitHub MCP server must be built from source using Go (not Docker) in the github-mcp-server directory to function properly.

```bash
cd ~/ppv/pillars/dotfiles/github-mcp-server
go build -o github-mcp-server ./cmd/github-mcp-server
```

## Configuration

Basic configuration:

```json
{
  "mcpServers": {
    "github": {
      "command": "~/ppv/pillars/dotfiles/github-mcp-server/github-mcp-server",
      "args": ["stdio"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

## Authentication

The GitHub MCP server requires a GitHub Personal Access Token with appropriate permissions:

```bash
# Add to your ~/.bash_secrets file
GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here
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

1. Verify your GitHub token has the correct permissions
2. Check if the server is running: `ps aux | grep github-mcp-server`
3. Look for error messages in the AI assistant's output
4. Run with debug logging: `Q_LOG_LEVEL=trace q chat --no-interactive`

## Additional Resources

- [GitHub MCP Server Documentation](https://github.com/github/github-mcp-server)
- [Model Context Protocol](https://modelcontextprotocol.github.io/)
