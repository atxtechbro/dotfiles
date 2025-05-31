# Clojure MCP Integration

This directory contains the configuration and scripts for integrating Clojure with the Model Context Protocol (MCP).

## Setup

To set up the Clojure MCP integration:

```bash
./setup-clojure-mcp.sh
```

## Usage

### Creating a New Project

To create a new Clojure project with MCP integration:

```bash
clj-mcp-new-project my-project
cd my-project
```

### Starting the nREPL Server

First, start an nREPL server in your project directory:

```bash
clojure -M:nrepl
```

This will start an nREPL server on port 7888.

### Starting the Clojure MCP Server

After the nREPL server is running, open a new terminal and start the Clojure MCP server:

```bash
clj-mcp-start
```

## Important: Two-Step Process

The Clojure MCP integration requires two separate processes:

1. **nREPL Server**: Provides the Clojure REPL environment
2. **Clojure MCP Server**: Connects to the nREPL server and exposes MCP tools

Both must be running for the integration to work properly.

## Troubleshooting

If you encounter a "Connection refused" error when starting the Clojure MCP server, it means the nREPL server is not running or not accessible on port 7888.

Steps to resolve:

1. Ensure you've started the nREPL server with `clojure -M:nrepl`
2. Check that the nREPL server is running on port 7888
3. Only then start the Clojure MCP server with `clj-mcp-start`

## Configuration

The Clojure MCP server is configured in `~/.clojure/deps.edn`.