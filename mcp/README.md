# Model Context Protocol (MCP) Configuration

This directory contains configuration files and setup scripts for Model Context Protocol (MCP) servers that can be used with various AI assistants like Amazon Q, Claude, and others.

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that standardizes how applications provide context to Large Language Models (LLMs). MCP enables communication between AI assistants and locally running MCP servers that provide additional tools and resources to extend their capabilities.

## Directory Structure

- `config-templates/` - Template configuration files for different MCP servers
- `setup.sh` - Script to set up MCP configurations for different AI assistants
- `servers/` - Documentation and setup scripts for specific MCP servers

## Supported AI Assistants

This configuration supports multiple AI assistants:

- Amazon Q CLI (`~/.amazonq/mcp.json`)
- Claude CLI (configuration location varies)
- (Add more as they become available)

## Usage

Run the setup script to configure MCP for your preferred AI assistant:

```bash
./mcp/setup.sh --assistant amazonq
```

Or manually link the configuration files:

```bash
# For Amazon Q
mkdir -p ~/.amazonq
ln -sf ~/ppv/pillars/dotfiles/mcp/config-templates/amazonq-mcp.json ~/.amazonq/mcp.json

# For other assistants, follow their specific configuration instructions
```

## Adding New MCP Servers

To add a new MCP server:

1. Add its configuration to the appropriate template file in `config-templates/`
2. Update the setup script to include the new server
3. Add documentation for the server in `servers/`

## Security Considerations

- MCP servers may require sensitive information like API keys or database credentials
- Consider using environment variables or a secrets manager for sensitive values
- The setup script can help inject these values from your `~/.bash_secrets` file
