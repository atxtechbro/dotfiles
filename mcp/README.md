# MCP Servers Integration

This directory contains wrapper scripts and configuration for MCP clients (Claude Code, OpenAI Codex, Claude Desktop, Cursor, VSCode, or Amazon Q).

## MCP Server Origins

Many of our MCP servers are sourced from the official [Model Context Protocol servers repository](https://github.com/modelcontextprotocol/servers), which provides a standardized collection of vetted MCP servers. This repository appears to be maintained with oversight from Anthropic and offers a consistent framework for building and deploying MCP servers.

Current servers from this source:
- Google Maps
- Brave Search
- Filesystem
- Google Drive

This standardized approach makes it easy to add more MCP servers in the future from this abundant collection.

## Available MCP Integrations

| Integration | Description | Authentication Method | Installation Method | Documentation |
|-------------|-------------|----------------------|---------------------|---------------|
| AWS Labs | AWS documentation, CDK | None required | PyPI packages via UVX | - |
| GitHub | GitHub API integration | Uses GitHub CLI token | Custom setup script | [Our Fork](https://github.com/atxtechbro/github-mcp-server?tab=readme-ov-file#github-mcp-server) |
| Atlassian | Jira and Confluence integration | API tokens from `.bash_secrets` | Custom setup script | - |
| Google Maps | Google Maps API integration | API key from `.bash_secrets` | Docker container | - |
| Brave Search | Web search via Brave | API key from `.bash_secrets` | Docker container | - |
| Filesystem | Local filesystem operations | None required | Built from source | [Our Fork](https://github.com/atxtechbro/mcp-servers/tree/main/src/filesystem#filesystem-mcp-server) |
| Git | Git repository operations | None required | Built from source | [Original Repo](https://github.com/cyanheads/git-mcp-server#git-mcp-server) |
| Google Drive | Google Drive file operations | OAuth credentials from `.bash_secrets` | Docker container | [Official Docs](https://github.com/modelcontextprotocol/servers/tree/main/src/gdrive#authentication) |
| MCP Shell | Secure shell command execution | None required | Built from source | [Original Repo](https://github.com/sonirico/mcp-shell) |

## Setup Instructions

Each MCP integration has its own setup method:

- **AWS Labs MCP Servers**: No setup script needed - these are installed automatically via UVX package manager from PyPI, making integration straightforward
- `setup-atlassian-mcp.sh` - Sets up Atlassian (Jira/Confluence) integration
- `setup-google-maps-mcp.sh` - Sets up Google Maps integration
- `setup-brave-search-mcp.sh` - Sets up Brave Search integration
- `setup-filesystem-mcp.sh` - Sets up Filesystem integration from source (allows customization)
- `setup-gdrive-mcp.sh` - Sets up Google Drive integration
- `setup-github-mcp.sh` - Sets up GitHub integration from source
- `setup-git-mcp.sh` - Sets up Git integration from source
- `setup-mcp-shell.sh` - Sets up MCP Shell integration with security controls

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

## Filesystem MCP Server Configuration

The Filesystem MCP server requires at least one allowed directory to be specified. By default, it uses your home directory (`$HOME`).

If you want to restrict filesystem access to specific directories:

```bash
# Set environment variable before starting Amazon Q
export MCP_FILESYSTEM_RESTRICT_DIRS="/projects:/data:/tmp"
q chat  # Start Amazon Q with restricted filesystem access
```

This allows you to control which directories the Filesystem MCP server can access.

## MCP Shell Server Configuration

The MCP Shell server provides fine-grained security controls for shell commands executed through Amazon Q CLI. The security configuration is stored in `mcp/config/mcp-shell.yaml`.

Key security features:
- **Command Whitelisting/Blacklisting**: Control which commands can be executed
- **Pattern Blocking**: Block dangerous command patterns (like `rm -rf /`)
- **Execution Limits**: Set timeouts and output size limits
- **Directory Restrictions**: Limit which directories commands can be executed in
- **Audit Logging**: Keep track of all executed commands

To install and set up the MCP Shell server:

```bash
# Install the MCP shell server
./utils/install-mcp-shell.sh

# Register it with Amazon Q CLI
./mcp/setup-mcp-shell.sh
```

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