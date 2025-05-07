# Model Context Protocol (MCP) Configuration

This directory contains configuration files and setup scripts for Model Context Protocol (MCP) servers that can be used with various AI assistants like Amazon Q, Claude, and others.

## Usage

MCP configuration is a two-step process:

### 1. Initial Installation

First, run the installation script to check dependencies and set up the default configuration:

```bash
# Install MCP with default personal configuration
bash mcp/install.sh
```

### 2. Configure Persona (Optional)

After installation, you can switch between different personas:

```bash
# For personal use (default)
bash mcp/setup.sh --persona personal

# For company/work use
bash mcp/setup.sh --persona company
```

## Troubleshooting

If you encounter issues with MCP servers:

1. Run the debug script to check your configuration:
   ```bash
   bash mcp/debug-mcp.sh
   ```

2. Common issues:
   - MCP servers not in PATH
   - Missing execute permissions
   - Incorrect configuration files
   - Missing dependencies

3. For Amazon Q specific debugging:
   ```bash
   Q_LOG_LEVEL=trace q chat
   ```

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that standardizes how applications provide context to Large Language Models (LLMs). MCP enables communication between AI assistants and locally running MCP servers that provide additional tools and resources to extend their capabilities.

## Directory Structure

- `config-templates/` - Template configuration files for different personas
- `setup.sh` - Script to set up MCP configurations for different personas
- `servers/` - Documentation and setup scripts for specific MCP servers
- `debug-mcp.sh` - Troubleshooting script for MCP configuration

## Persona-Based Configuration

This setup uses a persona-based approach to MCP configuration:

- **Personal** - Basic configuration for personal use
- **Company** - Enhanced configuration for work use

## Supported AI Assistants

This configuration supports multiple AI assistants:

- Amazon Q CLI (`~/.aws/amazonq/mcp.json`)
- Claude CLI (`~/.config/claude/mcp.json`)
- (Add more as they become available)

## MCP Servers

### GitHub MCP Server

The GitHub MCP server provides integration with GitHub repositories. It requires:

1. A GitHub Personal Access Token with 'repo' scope
2. The 'stdio' argument for proper communication

#### Configuration

The GitHub MCP server is configured in the MCP configuration file:

```json
{
  "mcpServers": {
    "github": {
      "command": "github-mcp-server",
      "args": ["stdio"],
      "env": {
        "GITHUB_TOKEN": "<YOUR_TOKEN>"
      },
      "timeout": 5000
    }
  }
}
```

#### Token Setup

You can set up your GitHub token in one of two ways:

1. Add it to your `.bash_secrets` file:
   ```bash
   # For personal use
   GITHUB_TOKEN=your_token_here
   
   # For company use
   COMPANY_GITHUB_TOKEN=your_token_here
   ```

2. Let the setup script prompt you for the token (interactive mode only)

#### Troubleshooting

If you encounter issues with the GitHub MCP server:

1. Check that the token is properly set
2. Verify that the 'stdio' argument is included
3. Run the debug script: `bash mcp/debug-mcp.sh`
4. Check the logs: `cat /tmp/mcp-logs/github-mcp-server.log`
