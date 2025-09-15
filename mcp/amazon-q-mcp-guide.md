# Amazon Q CLI MCP Server Management Guide

## Overview

The Amazon Q CLI provides comprehensive Model Context Protocol (MCP) server management capabilities, allowing you to add, remove, configure, and leverage MCP servers to extend Q's functionality with custom tools and resources.

## Key Capabilities

Based on the latest developments in the Amazon Q CLI repository, the MCP integration supports:

### Core MCP Features
- **Server Management**: Add, remove, list, and configure MCP servers
- **Tool Integration**: Access tools provided by MCP servers within Q chat sessions
- **Resource Support**: List, read, and use MCP resources (coming in PR #245)
- **Configuration Management**: Workspace and global server configurations
- **Status Monitoring**: Check server health and connection status

### Advanced Features
- **Multiple Configuration Paths**: Support for additional MCP config files via `--mcp-config-paths`
- **Environment Variables**: Custom environment setup for server launches
- **Timeout Configuration**: Configurable server launch timeouts
- **Disabled Servers**: Ability to disable servers without removing them
- **Tool Permissions**: Trust management for MCP server tools
- **Logging**: Comprehensive MCP operation logging

## Basic Commands

### Adding MCP Servers

```bash
# Basic server addition
q mcp add --name my-server --command "python -m my_mcp_server"

# With arguments
q mcp add --name git-server --command "uvx" --args "atxtechbro-git-mcp-server"

# With environment variables
q mcp add --name aws-server --command "uvx" --args "awslabs.eks-mcp-server" --env "AWS_REGION=us-west-2"

# Global vs workspace scope
q mcp add --name global-server --command "my-server" --scope global
q mcp add --name project-server --command "project-server" --scope workspace

# With timeout and disabled state
q mcp add --name slow-server --command "slow-server" --timeout 10000 --disabled
```

### Managing Servers

```bash
# List all configured servers
q mcp list

# Check server status
q mcp status --name my-server

# Remove a server
q mcp remove --name my-server

# Import configuration from file
q mcp import --file ./mcp-config.json
```

## Advanced Configuration

### Multiple Configuration Files

Use the `--mcp-config-paths` argument to specify additional configuration files:

```bash
# Single additional config
q chat --mcp-config-paths ~/shared-mcp-config.json

# Multiple configs (Unix/Mac: colon-separated, Windows: semicolon-separated)
q chat --mcp-config-paths ~/team-config.json:~/project-config.json
```

**Configuration Precedence**: global < workspace < additional paths (left to right)

### Environment Variables and Arguments

The `--args` flag supports flexible input formats:

```bash
# Format 1: Comma-separated in single --args
q mcp add --name eks-server --command uvx --args 'awslabs.eks-mcp-server,--allow-write,--allow-sensitive-data-access'

# Format 2: Multiple --args flags
q mcp add --name eks-server --command uvx --args awslabs.eks-mcp-server --args --allow-write --args --allow-sensitive-data-access
```

### Tool Trust Management

```bash
# Trust specific tools from MCP servers
q chat --trust-tools=git___git_status,filesystem___read_file

# Trust tools that may not be loaded yet (handles async server startup)
q chat --trust-tools=slow_server___some_tool
```

## Leveraging Our MCP Protocol Testing Knowledge

Based on our **subtraction-creates-value** work with git-mcp-server, here are key insights for maximizing Amazon Q MCP usage:

### Protocol-Level Validation

The Amazon Q CLI handles the full MCP handshake sequence:
1. `initialize` - Establishes protocol version and capabilities
2. `notifications/initialized` - Confirms initialization
3. `tools/list` - Retrieves available tools

**Key Insight**: Unlike CLI testing (`--help`), the Q CLI performs actual JSON-RPC communication, providing real validation of MCP server functionality.

### Server Development Best Practices

When developing MCP servers for use with Amazon Q:

1. **Minimal Configuration**: Follow the subtraction-creates-value principle - remove unnecessary complexity
2. **Protocol Compliance**: Ensure proper JSON-RPC handshake implementation
3. **Error Handling**: Implement graceful failure modes for network issues
4. **Tool Documentation**: Provide clear tool descriptions and parameter schemas

## Resource Management (Coming Soon)

PR #245 introduces MCP resource support:

```bash
# List available resources (when available)
q mcp resources list

# Read resource content (when available)
q mcp resources read --uri "file://path/to/resource"

# Use resource templates (when available)
q mcp resources templates
```

**Supported MIME Types**: Currently text and application/json (more formats planned)

## Configuration Examples

### Git MCP Server (Our Tested Example)

```bash
# Add our battle-tested git MCP server
q mcp add --name git-server --command "uvx" --args "atxtechbro-git-mcp-server"

# Verify it's working
q mcp status --name git-server

# Use in chat with trusted tools
q chat --trust-tools=git___git_status,git___git_diff_unstaged
```

### AWS EKS MCP Server

```bash
# Add AWS EKS server with permissions
q mcp add --name eks-server --command uvx \
  --args 'awslabs.eks-mcp-server,--allow-write,--allow-sensitive-data-access' \
  --env "AWS_REGION=us-west-2"
```

### Filesystem MCP Server

```bash
# Add filesystem server for file operations
q mcp add --name fs-server --command "uvx" --args "mcp-server-filesystem"
```

## Troubleshooting

### Common Issues

1. **Server Won't Start**: Check timeout settings and command paths
2. **Tools Not Available**: Verify server status and tool trust settings
3. **Permission Errors**: Review environment variables and file permissions
4. **Protocol Errors**: Use our MCP smoke test approach for validation

### Debugging Commands

```bash
# Check server status
q mcp status --name problematic-server

# Verbose logging
q chat -vvv --mcp-config-paths ~/debug-config.json

# List all servers and their states
q mcp list
```

### MCP Protocol Smoke Test

For server development, use our proven smoke test approach:

```bash
# Test MCP server directly (adapt for your server)
(echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "smoke-test", "version": "1.0.0"}}}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | your-mcp-server-command
```

## Integration Patterns

### Development Workflow

1. **Add Server**: Use `q mcp add` with appropriate configuration
2. **Verify Status**: Check `q mcp status` to ensure connectivity
3. **Trust Tools**: Use `--trust-tools` for required functionality
4. **Test Integration**: Validate tools work in chat sessions
5. **Iterate**: Adjust configuration based on usage patterns

### Team Collaboration

1. **Shared Configs**: Use `--mcp-config-paths` for team configurations
2. **Environment Separation**: Use workspace vs global scopes appropriately
3. **Documentation**: Document custom MCP servers and their capabilities
4. **Version Control**: Track MCP configurations in project repositories

## Future Enhancements

Based on ongoing development:

- **Enhanced Resource Support**: More MIME types and formats
- **Better Error Messages**: Improved debugging information
- **Performance Optimizations**: Faster server startup and communication
- **UI Improvements**: Better server management interfaces
- **Security Enhancements**: More granular permission controls

## Best Practices

1. **Start Simple**: Begin with basic server configurations
2. **Test Thoroughly**: Use protocol-level validation, not just CLI tests
3. **Document Everything**: Maintain clear server and tool documentation
4. **Monitor Performance**: Watch for server startup times and responsiveness
5. **Security First**: Use appropriate trust settings and environment isolation
6. **Iterate Quickly**: Leverage the tracer-bullets approach for rapid development

This guide reflects the current state of Amazon Q CLI MCP integration and incorporates lessons learned from our hands-on MCP server development experience.
