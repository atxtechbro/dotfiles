# Clojure MCP Integration

This directory contains the configuration and scripts for integrating Clojure with the Model Context Protocol (MCP).

## Overview

The Clojure MCP integration allows you to leverage REPL-driven development with any MCP-compatible AI assistant. This implementation demonstrates the "Snowball Method" in action:

1. **Persistent Context**: The REPL maintains state between evaluations
2. **Virtuous Cycle**: The more you use it, the more effective it becomes
3. **Knowledge Persistence**: Session history is preserved and enhanced over time
4. **Compounding Returns**: Small improvements accumulate and multiply
5. **Reduced Cognitive Load**: Less need to "re-learn" previous solutions

## Installation

The setup script (`setup-clojure-mcp.sh`) handles the installation and configuration of the Clojure MCP server. It follows the "Spilled Coffee Principle" by ensuring that the setup is reproducible across machines.

The script:
- Checks for required dependencies (Git, Java, Clojure)
- Configures the Clojure deps.edn file with the MCP server
- Creates wrapper scripts for starting the server
- Sets up templates for new projects

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
4. Make sure your AI assistant is configured to use the Clojure MCP server
