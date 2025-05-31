# Clojure MCP Integration

This directory contains the configuration and setup files for integrating Clojure's REPL-based workflow with MCP (Model Context Protocol) clients like Amazon Q, Claude, and GitHub Copilot.

## Overview

The Clojure MCP integration leverages the power of REPL-driven development to create a "snowball effect" where each development session builds on the accumulated knowledge of previous sessions, making AI assistants increasingly effective as your project evolves.

## Key Features

- **Client-Agnostic Design**: Works with any MCP-compatible client (Amazon Q, Claude, GitHub Copilot)
- **Persistent Context**: Maintains session history between development sessions
- **Incremental Development**: Supports the REPL-driven development workflow
- **Knowledge Accumulation**: Each session builds on previous ones
- **Automatic Client Detection**: Uses the first available MCP client or respects user preference

## Setup

The setup is handled by the `setup-clojure-mcp.sh` script in the parent directory:

```bash
cd ~/ppv/pillars/dotfiles/mcp
./setup-clojure-mcp.sh
```

This script:
1. Installs the Clojure MCP server
2. Creates necessary configuration files
3. Sets up bash aliases and functions
4. Registers the MCP server with available clients

## Usage

### Starting the Server

```bash
clj-mcp-start
```

This starts the Clojure MCP server on port 7777.

### Starting a REPL Session

```bash
clj-mcp
```

This automatically detects available MCP clients and starts a REPL session with the preferred one.

### Creating a New Project

```bash
clj-mcp-new-project my-project
```

Creates a new Clojure project with MCP integration.

### Saving and Loading Sessions

```bash
# Save the current session
clj-mcp-save-session my-session.edn

# Load a previous session
clj-mcp-load-session my-session.edn
```

## Configuration

The default configuration is stored in `~/.clojure-mcp/config.edn`. You can customize this file to change:

- Port number
- Host address
- Project directories
- History file location
- Maximum history entries

## Client-Specific Configuration

### Amazon Q

Amazon Q is automatically configured during setup if available.

### Claude

For Claude, ensure the Claude CLI is installed:

```bash
npm install -g @anthropic-ai/claude-code
```

### GitHub Copilot

For GitHub Copilot, ensure the GitHub CLI with Copilot extension is installed:

```bash
gh extension install github/gh-copilot
```

## Environment Variables

- `CLJ_MCP_CLIENT`: Set this to override the automatic client detection. Valid values: `q`, `claude`, `copilot`, `auto` (default)

## Troubleshooting

If you encounter issues:

1. Ensure the Clojure MCP server is running (`clj-mcp-start`)
2. Check that your preferred MCP client is installed and configured
3. Verify that port 7777 is not in use by another application
4. Check the server logs for any error messages

## References

- [bhauman/clojure-mcp](https://github.com/bhauman/clojure-mcp) - Original Clojure MCP implementation
- [Model Context Protocol (MCP)](https://github.com/mcp-sh/mcp) - The open protocol for providing context to LLMs