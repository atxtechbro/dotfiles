#!/bin/bash
# clojure-mcp-wrapper.sh - Wrapper script for Clojure MCP server
# This script follows the pattern of other MCP wrapper scripts in the repository

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if the server is already running
if pgrep -f "clojure.*:mcp" > /dev/null; then
  echo -e "${YELLOW}Clojure MCP server is already running${NC}"
  exit 0
fi

# Check for required dependencies
if ! command -v clojure &> /dev/null; then
  echo -e "${RED}Error: clojure is required but not installed.${NC}"
  echo -e "Please install clojure first."
  exit 1
fi

# Check if an nREPL server is running on port 7888
if ! nc -z localhost 7888 2>/dev/null; then
  echo -e "${RED}Error: No nREPL server found on port 7888${NC}"
  echo -e "Please start an nREPL server first with: ${YELLOW}clojure -M:nrepl${NC}"
  echo -e "Then run this command again."
  exit 1
fi

# Start the server
echo -e "${GREEN}Starting Clojure MCP server...${NC}"
exec clojure -X:mcp