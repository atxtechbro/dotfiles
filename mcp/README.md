# MCP Servers Integration

This directory contains wrapper scripts and configuration for MCP clients (Claude Code, OpenAI Codex, Claude Desktop, Cursor, VSCode, or Amazon Q).

## MCP Server Origins

Many of our MCP servers are sourced from the official [Model Context Protocol servers repository](https://github.com/modelcontextprotocol/servers), which provides a standardized collection of vetted MCP servers. This repository appears to be maintained with oversight from Anthropic and offers a consistent framework for building and deploying MCP servers.

Current servers from this source:
- Google Maps
- Brave Search
- Filesystem
- Google Drive
- Slack

This standardized approach makes it easy to add more MCP servers in the future from this abundant collection.

## Available MCP Integrations

| Integration | Description | Authentication Method | Installation Method |
|-------------|-------------|----------------------|---------------------|
| AWS Labs | AWS documentation, diagrams, CDK | None required | PyPI packages via UVX |
| GitHub | GitHub API integration | Uses GitHub CLI token | Custom setup script |
| Atlassian | Jira and Confluence integration | API tokens from `.bash_secrets` | Custom setup script |
| Google Maps | Google Maps API integration | API key from `.bash_secrets` | Docker container |
| Brave Search | Web search via Brave | API key from `.bash_secrets` | Docker container |
| Filesystem | Local filesystem operations | None required | Docker container |
| Google Drive | Google Drive file operations | OAuth credentials from `.bash_secrets` | Docker container |
| Slack | Slack messaging and search | Bot token from `.bash_secrets` | Docker container |

## Setup Instructions

Each MCP integration has its own setup method:

- **AWS Labs MCP Servers**: No setup script needed - these are installed automatically via UVX package manager from PyPI, making integration straightforward
- `setup-atlassian-mcp.sh` - Sets up Atlassian (Jira/Confluence) integration
- `setup-google-maps-mcp.sh` - Sets up Google Maps integration
- `setup-brave-search-mcp.sh` - Sets up Brave Search integration
- `setup-filesystem-mcp.sh` - Sets up Filesystem integration
- `setup-gdrive-mcp.sh` - Sets up Google Drive integration
- `setup-slack-mcp.sh` - Sets up Slack integration

For custom integrations, run the appropriate setup script:

```bash
# Example: Set up Google Maps integration
./setup-google-maps-mcp.sh
```

## Secret Management

All API keys and tokens are stored in `~/.bash_secrets` (not tracked in git) following our security best practices. The wrapper scripts load these secrets at runtime and pass them to the MCP servers.

To add your secrets:

1. Copy the template if you haven't already:
   ```bash
   cp ~/.bash_secrets.example ~/.bash_secrets
   ```

2. Edit the file to add your specific secrets:
   ```bash
   nano ~/.bash_secrets
   ```

3. Set proper permissions:
   ```bash
   chmod 600 ~/.bash_secrets
   ```

## Docker-based MCP Servers

Some MCP servers (like Google Maps) use Docker for containerization. The setup scripts handle building the Docker images and configuring the wrapper scripts.

Requirements:
- Docker installed and running
- Internet access to pull base images

## Configuration

The `mcp.json` file contains the configuration for all MCP servers. This file is used by Amazon Q and other MCP clients to discover and connect to the servers.

## Troubleshooting

If you encounter issues with an MCP integration:

1. Check that the required secrets are properly set in `~/.bash_secrets`
2. Verify that the wrapper script has execute permissions (`chmod +x wrapper-script.sh`)
3. For Docker-based integrations, ensure Docker is running (`docker ps`)
4. Check the logs from the MCP server for more detailed error messages
