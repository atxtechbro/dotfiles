# Model Context Protocol (MCP) Configuration

This directory contains configuration files and setup scripts for Model Context Protocol (MCP) servers that can be used with various AI assistants like Amazon Q, Claude, and others.

## Usage

Run the setup script to configure MCP for your preferred persona:

```bash
# For personal use
./mcp/setup.sh --persona personal

# For company/work use
./mcp/setup.sh --persona company
```

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that standardizes how applications provide context to Large Language Models (LLMs). MCP enables communication between AI assistants and locally running MCP servers that provide additional tools and resources to extend their capabilities.

## Directory Structure

- `config-templates/` - Template configuration files for different personas
- `setup.sh` - Script to set up MCP configurations for different personas
- `servers/` - Documentation and setup scripts for specific MCP servers

## Persona-Based Configuration

This setup uses a persona-based approach to MCP configuration:

- **Personal** - Basic configuration for personal use
- **Company** - Enhanced configuration for work use

## Supported AI Assistants

This configuration supports multiple AI assistants:

- Amazon Q CLI (`~/.amazonq/mcp.json`)
- Claude CLI (`~/.config/claude/mcp.json`)
- (Add more as they become available)

## Adding New MCP Servers

To add a new MCP server:

1. Add its configuration to the appropriate persona template file in `config-templates/`
2. Update the setup script if needed
3. Add documentation for the server in `servers/`

## Security Considerations

- MCP servers may require sensitive information like API keys or database credentials
- Consider using environment variables or a secrets manager for sensitive values
- The setup script can help inject these values from your `~/.bash_secrets` file
- Company-specific credentials should be prefixed with `COMPANY_` in your secrets file
