#!/bin/bash -x
# clojure-mcp-wrapper.sh - Robust wrapper script for Clojure MCP server
# Following the "Spilled Coffee Principle" - works regardless of where it's called from

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

# Define log file
LOG_FILE="/tmp/clojure-mcp-debug.log"

# Clear previous log
echo "=== Clojure MCP Wrapper Debug Log $(date) ===" > "$LOG_FILE"

# Log function
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
  echo "$1" >&2
}

# Log environment information
log "Starting Clojure MCP wrapper script"
log "Script directory: $SCRIPT_DIR"
log "Project directory: $PROJECT_DIR"
log "Current directory before switch: $(pwd)"
log "User: $(whoami)"
log "PATH: $PATH"

# Change to the project directory
cd "$PROJECT_DIR"
log "Changed to project directory: $(pwd)"

# Check if the server is already running
if pgrep -f "clojure.*:mcp" > /dev/null; then
  log "${YELLOW}Clojure MCP server is already running${NC}"
  exit 0
fi

# Check for required dependencies
if ! command -v clojure &> /dev/null; then
  log "${RED}Error: clojure is required but not installed.${NC}"
  log "Please install clojure first."
  exit 1
fi

# Check if deps.edn exists in the project directory
if [ ! -f "$PROJECT_DIR/deps.edn" ]; then
  log "${RED}Error: deps.edn not found in $PROJECT_DIR${NC}"
  log "Please ensure the deps.edn file exists with proper nREPL and MCP configurations."
  exit 1
fi

# Check if an nREPL server is running on port 7888
log "Checking for nREPL server on port 7888..."
if ! (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
  log "${YELLOW}No nREPL server found on port 7888. Starting one...${NC}"
  
  # Start nREPL server in the background
  clojure -M:nrepl &
  NREPL_PID=$!
  log "Started nREPL server with PID: $NREPL_PID"
  
  # Wait for nREPL server to start
  for i in {1..10}; do
    if (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
      log "${GREEN}nREPL server is now running on port 7888${NC}"
      break
    fi
    log "Waiting for nREPL server to start... ($i/10)"
    sleep 1
  done
  
  # Check if nREPL server started successfully
  if ! (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
    log "${RED}Error: Failed to start nREPL server${NC}"
    exit 1
  fi
else
  log "${GREEN}nREPL server already running on port 7888${NC}"
fi

# Use the MCP protocol to communicate with the client
echo '{"jsonrpc":"2.0","id":1,"method":"mcp.init","params":{"version":"0.1","capabilities":{}}}' >&2
log "Sent MCP initialization message"

# Start the MCP server
log "${GREEN}Starting Clojure MCP server...${NC}"
log "Using port 7888 for MCP server and nREPL connection"
log "Using deps.edn from: $PROJECT_DIR/deps.edn"

# Execute with full path to ensure consistency
cd "$PROJECT_DIR" && exec clojure -X:mcp 2>> "$LOG_FILE"
