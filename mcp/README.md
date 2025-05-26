# MCP Server Configuration

This directory contains configuration and scripts for managing Model Context Protocol (MCP) servers in a modular way.

## Overview

The MCP Server Configuration system allows you to:
- Maintain multiple implementations of the same MCP server type
- Switch between implementations seamlessly
- Isolate dependencies using virtual environments
- Preserve a consistent interface regardless of the underlying implementation

## Directory Structure

```
mcp/
├── config/                 # Configuration templates for different implementations
│   ├── git-cyanheads.json  # Configuration for cyanheads Git MCP server
│   ├── git-kzms.json       # Configuration for kzms Git MCP server
│   └── git-wrapper.json    # Configuration using the wrapper script
├── scripts/                # Utility scripts
│   ├── mcp-setup-implementation  # Script to set up a new implementation
│   ├── mcp-remove-implementation # Script to remove an implementation
│   └── mcp-switch          # Script to switch between implementations
├── setup-mcp.sh            # Setup script for MCP infrastructure
└── wrappers/               # Wrapper scripts for MCP servers
    └── git-mcp-wrapper.sh  # Wrapper for Git MCP server
```

## Setup

Run the setup script to create the necessary directory structure and symlinks:

```bash
./mcp/setup-mcp.sh
```

## Usage

### Setting Up a New Implementation

```bash
# Set up the kzms implementation for the git MCP server
mcp-setup-implementation git kzms https://github.com/atxtechbro/kzms-mcp-server-git.git

# Set up the cyanheads implementation for the git MCP server
mcp-setup-implementation git cyanheads https://github.com/cyanheads/git-mcp-server.git
```

### Switching Between Implementations

```bash
# Switch to the kzms implementation
mcp-switch git kzms

# Switch to the cyanheads implementation
mcp-switch git cyanheads
```

### Removing an Implementation

```bash
# Remove the kzms implementation for the git MCP server
mcp-remove-implementation git kzms
```

### Updating MCP Configuration

To use the wrapper script in your MCP configuration, copy the contents of `mcp/config/git-wrapper.json` to your `mcp/mcp.json` file.

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
