# MCP Servers Integration

This directory contains wrapper scripts and configuration for MCP clients (Claude Code, OpenAI Codex, Claude Desktop, Cursor, VSCode, or Amazon Q).

## MCP Server Origins

Many of our MCP servers are sourced from the official [Model Context Protocol servers repository](https://github.com/modelcontextprotocol/servers), which provides a standardized collection of vetted MCP servers. This repository appears to be maintained with oversight from Anthropic and offers a consistent framework for building and deploying MCP servers.

Current servers from this source:
- Brave Search
- Filesystem
- Google Drive

This standardized approach makes it easy to add more MCP servers in the future from this abundant collection.

## Server Locations Quick Reference

- Git MCP Server: `mcp/servers/git-mcp-server/src/mcp_server_git/server.py`

## Available MCP Integrations

| Integration | Description | Authentication Method | Installation Method | Documentation | Tool-Level Logging | Init-Level Logging |
|-------------|-------------|----------------------|---------------------|---------------|-------------------|-------------------|
| AWS Documentation | AWS documentation search | None required | PyPI packages via UVX | - | No | No |
| GitHub | GitHub API integration | Uses GitHub CLI token | Custom setup script | [Our Fork](https://github.com/atxtechbro/github-mcp-server?tab=readme-ov-file#github-mcp-server) | No | Yes |
| GitLab | GitLab API integration | `GITLAB_PERSONAL_ACCESS_TOKEN` from `.bash_secrets` | External npm package | https://github.com/zereight/gitlab-mcp | No | No |
| Atlassian | Jira and Confluence integration | API tokens from `.bash_secrets` | Custom setup script | - | No | Yes |
| Brave Search | Web search via Brave | API key from `.bash_secrets` | Docker container | - | No | Yes |
| Filesystem | Local filesystem operations | None required | Built from source | [Our Fork](https://github.com/atxtechbro/mcp-servers/tree/main/src/filesystem#filesystem-mcp-server) | No | Yes |
| Git | Git repository operations | None required | Source lives in dotfiles | [README.md](servers/git-mcp-server/README.md) | Yes | Yes |
| Google Drive | Google Drive file operations | OAuth credentials from `.bash_secrets` | Docker container | [Our Fork](https://github.com/atxtechbro/mcp-servers/tree/main/src/gdrive#authentication) | No | Yes |

## Setup Instructions

Each MCP integration has its own setup method:

- **AWS Documentation MCP Server**: No setup script needed - installed automatically via UVX package manager from PyPI
- `setup-atlassian-mcp.sh` - Sets up Atlassian (Jira/Confluence) integration
- `setup-brave-search-mcp.sh` - Sets up Brave Search integration
- `setup-filesystem-mcp.sh` - Sets up Filesystem integration from source (allows customization)
- `setup-gdrive-mcp.sh` - Sets up Google Drive integration
- `setup-github-mcp.sh` - Sets up GitHub integration from source
- `setup-git-mcp.sh` - Sets up Git integration from source
- `setup-gitlab-mcp.sh` - Sets up external GitLab integration

For custom integrations, run the appropriate setup script:

```bash
# Example: Set up Brave Search integration
./setup-brave-search-mcp.sh
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

Some MCP servers use Docker for containerization. The setup scripts handle building the Docker images and configuring the wrapper scripts.

Requirements:
- Docker installed and running
- Internet access to pull base images

## Configuration

The MCP configuration follows a vendor-agnostic pattern:

- **Canonical location**: `mcp/mcp.json` - The single source of truth for MCP configuration
- **Claude Code compatibility**: `.mcp.json` symlink at repository root points to `mcp/mcp.json`
- **Setup**: Run `./setup-vendor-agnostic-mcp.sh` to configure the vendor-agnostic structure

This approach allows us to maintain a single MCP configuration file while supporting multiple MCP clients through symlinks or client-specific configurations.

## Filesystem MCP Server Configuration

The Filesystem MCP server requires at least one allowed directory to be specified. By default, it uses your home directory (`$HOME`).

If you want to restrict filesystem access to specific directories:

```bash
# Set environment variable before starting Amazon Q
export MCP_FILESYSTEM_RESTRICT_DIRS="/projects:/data:/tmp"
q chat  # Start Amazon Q with restricted filesystem access
```

This allows you to control which directories the Filesystem MCP server can access.

## Protocol Testing

When modifying MCP servers, test the actual JSON-RPC protocol communication instead of just CLI help text.

**Complete MCP handshake test:**
```bash
(echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "smoke-test", "version": "1.0.0"}}}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | .venv/bin/python -m mcp_server_git -r .
```

**Expected success response:**
- Initialize: Returns protocol version and server capabilities
- tools/list: Returns actual tool definitions with JSON schemas
- No error responses in the JSON-RPC output

**Why this matters:** CLI testing (`--help`) only validates the command wrapper, not the MCP protocol that real clients use. This provides confidence that actual MCP clients can communicate with the server.

**Use cases:**
- After server modifications or cleanup
- Before committing MCP server changes  
- When debugging client integration issues
- During subtraction/refactoring work

## Troubleshooting

If you encounter issues with an MCP integration:

1. **Check MCP error logs**: Run `check-mcp-logs` to see recent MCP server errors and tool calls
2. Check that the required secrets are properly set in `~/.bash_secrets`
3. Verify that the wrapper script has execute permissions (`chmod +x wrapper-script.sh`)
4. For Docker-based integrations, ensure Docker is running (`docker ps`)
5. Check the logs from the MCP server for more detailed error messages

### MCP Error Logging Framework

**Fundamental Problem**: Most MCP clients (including Amazon Q CLI, Claude Desktop, etc.) provide weak or no logging, often suppressing or hiding MCP server errors entirely. This makes debugging MCP integration issues extremely difficult.

**Setup vs Wrapper Scripts**:
- **Setup scripts** run once manually with visible terminal feedback ✅
- **Wrapper scripts** run many times daily behind the scenes with hidden output ❌

All MCP wrapper scripts now implement enhanced error handling with:

- **Error logging** to `~/mcp-errors.log` with timestamps and server identification
- **Tool-level logging** to `~/mcp-tool-calls.log` for individual MCP tool executions (where supported)
- **Desktop notifications** on macOS for critical failures  
- **Actionable error messages** with specific remediation steps
- **Consistent error format**: `[SERVER] MCP ERROR: [description]`

#### Using the Error Logging System

Use the `check-mcp-logs` utility to:

- `check-mcp-logs` - Show recent errors and tool calls
- `check-mcp-logs --errors` - Show only initialization/server errors
- `check-mcp-logs --tools` - Show only tool call logs
- `check-mcp-logs --follow` - Follow logs in real-time  
- `check-mcp-logs --lines 50` - Show last 50 lines

#### Tool-Level Logging

For MCP servers with tool-level logging support (currently: Git), each tool call is logged with:
- Timestamp and current git branch
- Tool name and parameters passed
- Success/failure status with error messages
- Repository context and execution details

This provides visibility into individual MCP operations that would otherwise be hidden by MCP clients.

#### Adding Logging to New Wrapper Scripts

When creating new MCP wrapper scripts:

1. **Source the logging utilities**:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/utils/mcp-logging.sh"
   ```

2. **Use the logging functions**:
   ```bash
   # Check secrets file and source it
   mcp_source_secrets "SERVER_NAME"
   
   # Check environment variables
   mcp_check_env_var "SERVER_NAME" "API_KEY" "Add: export API_KEY=\"your_key\""
   
   # Check Docker (for Docker-based servers)
   mcp_check_docker "SERVER_NAME"
   
   # Check commands
   mcp_check_command "SERVER_NAME" "node" "Install Node.js: brew install node"
   
   # Custom error logging
   mcp_log_error "SERVER_NAME" "Custom error message" "Optional remediation steps"
   ```

3. **Use consistent server names**: BRAVE, ATLASSIAN, GITHUB, GIT, FILESYSTEM, GDRIVE

#### Adding Tool-Level Logging to MCP Servers

For MCP servers implemented in Python (like git-mcp-server), add comprehensive tool-level logging:

##### Log Entry Structure Taxonomy

Each MCP tool call generates a single line with this structured format:

**Dynamic Identifiers:**
- Timestamp: `2025-06-18 13:04:33:` (when the call occurred)
- Server name: `[atxtechbro-git-mcp-server]` (which MCP server handled it)
- Tool name: `git_add` (specific tool invoked)

**Structured Metadata Fields (UPPERCASE):**
- `TOOL_CALL:` - Fixed label identifying this as a tool invocation
- `STATUS:` - Success/failure indicator (SUCCESS/ERROR)
- `BRANCH:` - Current git branch context (when applicable)
- `DETAILS:` - Human-readable summary of what happened
- `PARAMS:` - JSON parameters passed to the tool

This taxonomy enables both human scanning and programmatic parsing. Dynamic identifiers provide context (what/when/where), while uppercase fields create consistent data categories across all MCP servers.

1. **Create logging utilities module** (`logging_utils.py`):
   ```python
   from datetime import datetime
   from pathlib import Path
   from typing import Optional
   import json
   import subprocess
   
   def log_tool_call(server_name: str, tool_name: str, status: str, 
                     details: str, repo_path: Optional[Path] = None, 
                     parameters: Optional[dict] = None) -> None:
       # Implementation similar to git-mcp-server/src/mcp_server_git/logging_utils.py
   ```

2. **Import and wrap tool calls** in your server's `call_tool()` function:
   ```python
   from .logging_utils import log_tool_success, log_tool_error
   
   @server.call_tool()
   async def call_tool(name: str, arguments: dict) -> list[TextContent]:
       try:
           # Repository/context setup with error handling
           repo_path = Path(arguments.get("repo_path", "."))
           
           match name:
               case "your_tool":
                   result = your_tool_function(arguments)
                   log_tool_success("your-server-name", name, 
                                  "Tool-specific success message", 
                                  repo_path, arguments)
                   return [TextContent(type="text", text=result)]
                   
       except Exception as e:
           error_msg = f"Tool execution failed: {str(e)}"
           log_tool_error("your-server-name", name, error_msg, 
                         repo_path, arguments)
           return [TextContent(type="text", text=f"Error: {error_msg}")]
   ```

3. **Log context for each tool**:
   - **Success logs**: Tool name, operation details, parameters
   - **Error logs**: Tool name, error message, parameters, context
   - **Repository context**: Current branch, repo path (if applicable)
   - **Timestamps**: Automatic via logging utilities

4. **Update documentation**:
   - Add "Yes" to Tool-Level Logging column in MCP integrations table
   - Document tool-level logging in server's README
   - Include examples of log output format

This framework bridges the visibility gap created by MCP clients that suppress wrapper script errors and provides detailed insight into individual tool operations.
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
