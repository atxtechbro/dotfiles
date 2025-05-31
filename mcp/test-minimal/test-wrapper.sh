#!/bin/bash -x
# Simple wrapper script for testing Clojure MCP

# Define log file
LOG_FILE="/tmp/clojure-mcp-test.log"
echo "=== Clojure MCP Test Log $(date) ===" > "$LOG_FILE"

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "Current directory: $(pwd)" | tee -a "$LOG_FILE"
echo "Script directory: $SCRIPT_DIR" | tee -a "$LOG_FILE"

# Check if an nREPL server is running on port 7888
if ! (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
  echo "No nREPL server found on port 7888. Starting one..." | tee -a "$LOG_FILE"
  clojure -M:nrepl &
  NREPL_PID=$!
  echo "Started nREPL server with PID: $NREPL_PID" | tee -a "$LOG_FILE"
  
  # Wait for nREPL server to start
  for i in {1..10}; do
    if (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
      echo "nREPL server is now running on port 7888" | tee -a "$LOG_FILE"
      break
    fi
    echo "Waiting for nREPL server to start... ($i/10)" | tee -a "$LOG_FILE"
    sleep 1
  done
else
  echo "nREPL server already running on port 7888" | tee -a "$LOG_FILE"
fi

# Use the MCP protocol to communicate with the client
echo '{"jsonrpc":"2.0","id":1,"method":"mcp.init","params":{"version":"0.1","capabilities":{}}}' | tee -a "$LOG_FILE"

# Start the MCP server
echo "Starting Clojure MCP server..." | tee -a "$LOG_FILE"
exec clojure -X:mcp 2>> "$LOG_FILE"
