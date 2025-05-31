# Clojure MCP Integration

This directory contains the configuration and scripts for integrating Clojure with the Model Context Protocol (MCP).

## Overview

The Clojure MCP integration allows you to use AI assistants like Amazon Q or Claude with your Clojure REPL environment. This follows the "Snowball Method" principle from our dotfiles philosophy, creating a virtuous cycle where each development session builds on the accumulated knowledge of previous sessions.

## How It Works

The integration consists of two main components:

1. **nREPL Server**: A Clojure REPL environment that runs on port 7888
2. **Clojure MCP Server**: Connects to the nREPL server and exposes MCP tools to AI assistants

The wrapper script (`clojure-mcp-wrapper.sh`) handles both components automatically:
- It checks if an nREPL server is running on port 7888
- If no nREPL server is found, it starts one automatically
- It then starts the Clojure MCP server that connects to the nREPL server

## Usage

### Option 1: Using with Amazon Q or Claude Desktop

Simply start your AI assistant (Amazon Q or Claude Desktop) and it will automatically use the wrapper script to connect to the Clojure MCP server.

### Option 2: Manual Usage

You can also run the wrapper script manually:

```bash
cd /home/linuxmint-lp/ppv/pillars/dotfiles
./mcp/clojure-mcp-wrapper.sh
```

## Configuration

The configuration is defined in the `deps.edn` file in the project root:

```clojure
:aliases {
  ;; nREPL server configuration
  :nrepl {:extra-deps {nrepl/nrepl {:mvn/version "1.3.1"}}
          :main-opts ["-m" "nrepl.cmdline" "--port" "7888"]},
  
  ;; MCP server configuration
  :mcp {:deps {org.slf4j/slf4j-nop {:mvn/version "2.0.16"}
               com.bhauman/clojure-mcp {:git/url "https://github.com/bhauman/clojure-mcp.git"
                                        :git/sha "83627e7095f0ebab3d5503a5b2ee94aa6953cb0d"}}
        :exec-fn clojure-mcp.main/start-mcp-server
        :exec-args {:port 7888
                    :host "localhost"}}}
```

## Troubleshooting

If you encounter issues with the Clojure MCP integration:

1. Check if the nREPL server is running:
   ```bash
   nc -zv localhost 7888
   ```

2. Check the debug log for any errors:
   ```bash
   cat /tmp/clojure-mcp-debug.log
   ```

3. For Claude Desktop, check the MCP server logs:
   ```bash
   cat ~/.config/Claude/logs/mcp-server-clojure-mcp.log
   ```

4. Try running the minimal test case:
   ```bash
   cd /home/linuxmint-lp/ppv/pillars/dotfiles/mcp/test-minimal
   ./test-wrapper.sh
   ```

## Key Implementation Details

- The wrapper script follows the "Spilled Coffee Principle" - it works regardless of where it's called from
- The `host` parameter is explicitly set to "localhost" in the configuration to ensure proper connection
- The script automatically starts the nREPL server if it's not already running
- The script uses absolute paths to ensure consistency across different environments
