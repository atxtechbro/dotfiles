# MCP Servers Integration

This directory contains wrapper scripts and configuration for Model Context Protocol (MCP) servers used with Amazon Q and other MCP-compatible clients.

## Available MCP Integrations

| Integration | Description | Authentication Method |
|-------------|-------------|----------------------|
| GitHub | GitHub API integration | Uses GitHub CLI token |
| Atlassian | Jira and Confluence integration | API tokens from `.bash_secrets` |
| Google Maps | Google Maps API integration | API key from `.bash_secrets` |

## Setup Instructions

Each MCP integration has its own setup script that handles installation and configuration:

- `setup-atlassian-mcp.sh` - Sets up Atlassian (Jira/Confluence) integration
- `setup-google-maps-mcp.sh` - Sets up Google Maps integration

Run the appropriate setup script to configure the integration:

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
