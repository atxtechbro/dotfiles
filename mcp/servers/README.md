# MCP Servers

This directory contains Model Context Protocol (MCP) servers that extend the capabilities of AI assistants like Amazon Q, Claude, and GitHub Copilot.

## Current Servers

### filesystem-mcp-server
A server that provides file system operations like reading, writing, and navigating directories.
- Repository: [atxtechbro/filesystem-mcp-server](https://github.com/atxtechbro/filesystem-mcp-server)

### github-mcp-server
A server that provides GitHub API integration, allowing AI assistants to interact with GitHub repositories.
- Repository: [atxtechbro/github-mcp-server](https://github.com/atxtechbro/github-mcp-server)
- Upstream: [github/github-mcp-server](https://github.com/github/github-mcp-server)

### git-mcp-server
A server that provides Git operations, allowing AI assistants to interact with local Git repositories.
- Repository: [atxtechbro/git-mcp-server](https://github.com/atxtechbro/git-mcp-server)

### mcp-servers
A collection of MCP servers and utilities.
- Repository: [atxtechbro/mcp-servers](https://github.com/atxtechbro/mcp-servers)

## Binary Files

- `github`: Binary executable for the GitHub MCP server

## Usage

These servers are automatically configured and started by the setup scripts in the parent directory. They follow the "Spilled Coffee Principle" from our dotfiles philosophy, ensuring that your AI assistant capabilities can be quickly restored after a system reset.

## Adding New Servers

When adding new MCP servers:

1. Clone the repository into this directory
2. Update this README.md with information about the new server
3. Add any necessary setup scripts to the parent directory
4. Follow the "Versioning Mindset" by documenting any special configuration or usage notes

## Maintenance

To update existing servers, navigate to their directories and pull the latest changes:

```bash
cd ~/ppv/pillars/dotfiles/mcp/servers/github-mcp-server
git pull
```

For binary files, check the respective repositories for update instructions.