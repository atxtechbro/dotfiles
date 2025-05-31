#!/bin/bash
# clojure-mcp-wrapper.sh - Wrapper script for Clojure MCP server
# This script follows the pattern of other MCP wrapper scripts in the repository

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Check if an nREPL server is running on port 7888
log "Checking for nREPL server on port 7888..."
if ! (echo > /dev/tcp/localhost/7888) 2>/dev/null; then
  log "${RED}Error: No nREPL server found on port 7888${NC}"
  log "Please start an nREPL server first with: ${YELLOW}clojure -M:nrepl${NC}"
  log "Then run this command again."
  exit 1
fi

# Use the MCP protocol to communicate with the client
echo '{"jsonrpc":"2.0","id":1,"method":"mcp.init","params":{"version":"0.1","capabilities":{}}}' >&2
log "Sent MCP initialization message"

# Start the MCP server
log "${GREEN}Starting Clojure MCP server...${NC}"
log "Using port 7888 to connect to nREPL server"
exec clojure -X:mcp 2>> "$LOG_FILE"
