#!/bin/bash
# clojure-mcp-wrapper.sh - Wrapper script for Clojure MCP server
# This script follows the pattern of other MCP wrapper scripts in the repository

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
log "Current directory: $(pwd)"
log "Script location: $(readlink -f "$0")"
log "User: $(whoami)"
log "PATH: $PATH"

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Check if netcat is available for port checking
if ! command -v nc &> /dev/null; then
  log "${YELLOW}Warning: nc command not found, using alternative method to check port${NC}"
  # Alternative method to check if port is open
  if ! (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
    log "${RED}Error: No nREPL server found on port 7888${NC}"
    log "Please start an nREPL server first with: ${YELLOW}clojure -M:nrepl${NC}"
    log "Then run this command again."
    exit 1
  fi
else
  # Check if an nREPL server is running on port 7888
  if ! nc -z localhost 7888 2>/dev/null; then
    log "${RED}Error: No nREPL server found on port 7888${NC}"
    log "Please start an nREPL server first with: ${YELLOW}clojure -M:nrepl${NC}"
    log "Then run this command again."
    exit 1
  fi
fi

# Log that we're starting the server
log "${GREEN}Starting Clojure MCP server...${NC}"

# Use the MCP protocol to communicate with the client
echo '{"jsonrpc":"2.0","id":1,"method":"mcp.init","params":{"version":"0.1","capabilities":{}}}' >&2
log "Sent MCP initialization message"

# Run the server with proper error handling
log "Executing: clojure -X:mcp"
exec clojure -X:mcp 2>> "$LOG_FILE"