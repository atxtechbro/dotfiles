# Minimal Clojure MCP Test Case

This is a minimal test case for troubleshooting the Clojure MCP integration. It contains only the essential components needed to test the integration between the nREPL server and the Clojure MCP server.

## Directory Structure

```
test-minimal/
├── deps.edn         # Minimal dependencies configuration
├── src/
│   └── user/
│       └── core.clj # Simple Clojure source file
└── test-wrapper.sh  # Test wrapper script
```

## How to Test

1. Run the test wrapper script:

```bash
cd /home/linuxmint-lp/ppv/pillars/dotfiles/mcp/test-minimal
./test-wrapper.sh
```

The script will:
- Check if an nREPL server is running on port 7888
- Start an nREPL server if one is not already running
- Wait for the nREPL server to start
- Send the MCP initialization message
- Start the Clojure MCP server

2. Check the log file for any errors:

```bash
cat /tmp/clojure-mcp-test.log
```

## Troubleshooting

If the test fails, check the following:

1. Is the nREPL server running on port 7888?
   ```bash
   nc -zv localhost 7888
   ```

2. Are there any errors in the log file?
   ```bash
   cat /tmp/clojure-mcp-test.log
   ```

3. Is the Clojure MCP server trying to connect to the correct port?
   ```bash
   grep "port" /home/linuxmint-lp/ppv/pillars/dotfiles/mcp/test-minimal/deps.edn
   ```
