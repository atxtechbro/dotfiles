# Clojure MCP Integration

This directory contains the configuration and scripts for integrating Clojure with the Model Context Protocol (MCP).

## Usage

### Starting the Clojure MCP Server

To start the Clojure MCP server:

```bash
clj-mcp-start
```

### Starting a REPL Session

In a new terminal, start a REPL session:

```bash
cd /path/to/your/project
clojure -M:nrepl
```

### Creating a New Project

To create a new Clojure project with MCP integration:

```bash
clj-mcp-new-project my-project
cd my-project
clojure -M:nrepl
```

### Saving and Loading REPL Sessions

To save the current session:

```bash
clj-mcp-save-session my-session.edn
```

To load a previous session:

```bash
clj-mcp-load-session my-session.edn
```

### Generating a Project Summary

To generate a project summary based on your REPL history:

```bash
clj-mcp-summarize
```

## Configuration

The Clojure MCP server is configured in `~/.clojure/deps.edn`.

## Troubleshooting

If you encounter issues:

1. Check that the nREPL server is running on port 7888
2. Verify that the Clojure MCP server is running
3. Check for error messages in the terminal where the server is running
