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
|-------------|-------------|------------------------|---------------------|
| AWS Labs | AWS documentation, diagrams, CDK | None required | PyPI packages via UVX |
| GitHub | GitHub API integration | Uses GitHub CLI token | Custom setup script |
| Atlassian | Jira and Confluence integration | API tokens from `.bash_secrets` | Custom setup script |
| Google Maps | Google Maps API integration | API key from `.bash_secrets` | Docker container |
| Brave Search | Web search via Brave | API key from `.bash_secrets` | Docker container |
| Filesystem | Local filesystem operations | None required | Docker container |
| Google Drive | Google Drive file operations | OAuth credentials from `.bash_secrets` | Docker container |
| Slack | Slack messaging and search | Bot token from `.bash_secrets` | Docker container |

## MCP Toggle System

The MCP Toggle System allows you to easily enable or disable MCP servers without editing complex JSON configuration files.

### Getting Started

Initialize your configuration:

```bash
./mcp/mcp-toggle.sh init
```

This creates a `.mcp-enabled-servers` file in your home directory with default settings.

### Managing MCP Servers

List available and enabled servers:

```bash
./mcp/mcp-toggle.sh list
```

Enable a server (set to 1):

```bash
./mcp/mcp-toggle.sh on brave-search
```

Disable a server (set to 0):

```bash
./mcp/mcp-toggle.sh off gdrive
```

Apply your changes:

```bash
./mcp/mcp-toggle.sh apply
```

### Configuration File

The configuration file at `~/.mcp-enabled-servers` uses a simple key=value format:
- `server=1` means the server is enabled
- `server=0` means the server is disabled

Example:
```
# Core servers
github=1
atlassian=1

# Search servers
brave-search=1
google-maps=0
```

You can edit this file directly and then run `mcp-toggle.sh apply` to update your configuration.

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
## Adding New MCP Servers

Based on our current experience, here's a working procedure for adding new MCP servers (subject to improvement as we learn more):

1. **Start with mcp.json configuration**:
   - Add the server entry to `mcp.json` first, even if the wrapper script doesn't exist yet
   - Define the command, args, and environment variables needed

2. **Create the wrapper script**:
   - Implement `<server-name>-mcp-wrapper.sh` that handles authentication and execution
   - Ensure it properly sources credentials from `~/.bash_secrets` if needed

3. **Implement the setup script**:
   - Create `setup-<server-name>-mcp.sh` for one-time setup tasks
   - For Docker-based servers, include image building steps
   - For package-based servers, document installation requirements

4. **Document the integration**:
   - Add an entry to the MCP Integrations table in the README
   - Classify the server by source, authentication method, and installation approach
   - Create test documentation in `tests/test-<server-name>.md`

This workflow represents our current understanding and approach, which we expect to refine as we gain more experience with different types of MCP servers and discover better patterns for integration.
## Utility Functions

To reduce code duplication and ensure consistent behavior across setup scripts, we use shared utility functions in the `utils/` directory:

- `mcp-setup-utils.sh` - Common functions for MCP server setup scripts

These utilities handle common tasks like:
- Checking prerequisites (Docker, repository structure)
- Setting up the MCP servers repository
- Building Docker images
- Updating secrets templates
- Printing consistent setup completion messages

See the [utils/README.md](utils/README.md) file for more details on available functions and usage.