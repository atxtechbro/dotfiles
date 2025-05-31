# Clojure MCP Integration

This directory contains the configuration and scripts for integrating Clojure with the Model Context Protocol (MCP).

## Important: Two-Step Process

The Clojure MCP integration requires two separate processes:

1. **nREPL Server**: Provides the Clojure REPL environment
2. **Clojure MCP Server**: Connects to the nREPL server and exposes MCP tools

Both must be running for the integration to work properly.

## Setup Instructions

### Step 1: Configure Your Project

Make sure your project has the nREPL configuration in `deps.edn`:

```clojure
{:aliases {
  ;; nREPL server for AI to connect to
  :nrepl {:extra-paths ["test"] 
          :extra-deps {nrepl/nrepl {:mvn/version "1.3.1"}}
          :jvm-opts ["-Djdk.attach.allowAttachSelf"]
          :main-opts ["-m" "nrepl.cmdline" "--port" "7888"]}}}
```

### Step 2: Start the nREPL Server

Start an nREPL server in your project directory:

```bash
cd /path/to/your/project
clojure -M:nrepl
```

You should see: `nREPL server started on port 7888 on host localhost - nrepl://localhost:7888`

### Step 3: Use Amazon Q with Clojure MCP

After the nREPL server is running, you can use Amazon Q which will automatically connect to the Clojure MCP server.

## Troubleshooting

If you encounter a "Connection refused" error when starting the Clojure MCP server, it means the nREPL server is not running or not accessible on port 7888.

Steps to resolve:

1. Ensure you've started the nREPL server with `clojure -M:nrepl`
2. Check that the nREPL server is running on port 7888
3. Then try using Amazon Q again

## Advanced Configuration

For advanced configuration options, see the [official Clojure MCP documentation](https://github.com/bhauman/clojure-mcp).
