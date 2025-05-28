# MCP Server Configuration

This directory contains configuration and scripts for managing Model Context Protocol (MCP) servers in a modular way.

## Overview

The MCP Server Configuration system allows you to:
- Maintain multiple implementations of the same MCP server type
- Switch between implementations seamlessly
- Isolate dependencies using virtual environments
- Preserve a consistent interface regardless of the underlying implementation
- Detect and use locally built implementations

## Directory Structure

```
mcp/
├── config/                 # Configuration templates for different implementations
│   ├── git-cyanheads.json  # Configuration for cyanheads Git MCP server
│   ├── git-kzms.json       # Configuration for kzms Git MCP server
│   └── git-wrapper.json    # Configuration using the wrapper script
├── scripts/                # Utility scripts
│   ├── mcp-server          # Unified command for managing MCP servers
│   ├── mcp-setup-implementation  # Script to set up a new implementation
│   ├── mcp-remove-implementation # Script to remove an implementation
│   └── mcp-switch          # Script to switch between implementations
├── servers/                # Directory for locally built MCP servers
│   └── github-mcp-server/  # Example of a locally built server
├── setup-mcp.sh            # Setup script for MCP infrastructure
└── wrappers/               # Wrapper scripts for MCP servers
    └── git-mcp-wrapper.sh  # Wrapper for Git MCP server
```

## Setup

Run the setup script to create the necessary directory structure and symlinks:

```bash
./mcp/setup-mcp.sh
```

This script will:
- Create the required directories for MCP server implementations
- Create directories for virtual environments
- Set up configuration directories
- Create symlinks for wrapper and utility scripts in `~/ppv/pillars/dotfiles/bin`

## Usage

### Listing Available Implementations

```bash
# List all available MCP servers and implementations
mcp-server list
```

### Adding a New Implementation

```bash
# Add a new implementation for the git MCP server
mcp-server add git kzms https://github.com/atxtechbro/kzms-mcp-server-git.git

# Add a new implementation for the git MCP server
mcp-server add git cyanheads https://github.com/cyanheads/git-mcp-server.git
```

### Switching Between Implementations

```bash
# Switch to a different implementation
mcp-server update git kzms
```

### Removing an Implementation

```bash
# Remove an implementation
mcp-server remove git kzms
```

### Building from Source

For locally built MCP servers:

1. Clone the repository into the `mcp/servers` directory:
```bash
git clone https://github.com/example/example-mcp-server.git ~/ppv/pillars/dotfiles/mcp/servers/example-mcp-server
```

2. Build the server (if needed):
```bash
cd ~/ppv/pillars/dotfiles/mcp/servers/example-mcp-server
make build
```

3. The server will be automatically detected by the `mcp-server list` command.

### Updating MCP Configuration

To use the wrapper script in your MCP configuration, copy the contents of `mcp/config/git-wrapper.json` to your `~/.aws/amazonq/mcp.json` file.

## Git Worktree Support

When working with git worktrees, the setup script automatically detects if it's running in a worktree and creates symlinks that point to the correct location. This allows you to test your changes in worktrees without manual intervention.

## Troubleshooting

### Implementation Not Found

If you see an error like "No implementation found for git MCP server", check:
1. The active implementation is correctly set
2. The implementation directory exists
3. The virtual environment is properly set up

### Virtual Environment Issues

If you encounter issues with the virtual environment:
1. Recreate the virtual environment: `uv venv ~/ppv/pipelines/venvs/mcp-servers/git-kzms --force`
2. Reinstall the package: `~/ppv/pipelines/venvs/mcp-servers/git-kzms/bin/uv pip install -e ~/.local/share/mcp-servers/python/git/kzms`

### Symlink Issues

If commands like `mcp-server` are not found:
1. Make sure `~/ppv/pillars/dotfiles/bin` is in your PATH
2. Run `./mcp/setup-mcp.sh` to recreate the symlinks
3. Check if you're in a git worktree and if the symlinks point to the correct location