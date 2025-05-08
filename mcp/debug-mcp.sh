#!/bin/bash
# Debug script for Amazon Q MCP
# This script helps diagnose issues with MCP server initialization

# Set up colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== MCP Configuration Diagnostics ===${NC}"
echo -e "${BLUE}=====================================${NC}"

echo -e "\n${BLUE}Checking MCP configuration...${NC}"
echo -e "${BLUE}-----------------------------${NC}"

# Check if the MCP config file exists
if [ -f "$HOME/.aws/amazonq/mcp.json" ]; then
  echo -e "${GREEN}✓ MCP config file exists:${NC} $HOME/.aws/amazonq/mcp.json"
  echo -e "${BLUE}To view contents:${NC} cat $HOME/.aws/amazonq/mcp.json"
else
  echo -e "${RED}✗ MCP config file not found:${NC} $HOME/.aws/amazonq/mcp.json"
fi

echo -e "\n${BLUE}Testing Amazon Q CLI with MCP...${NC}"
echo -e "${BLUE}----------------------------${NC}"
echo -e "${YELLOW}(This will timeout after 13 seconds if stuck)${NC}"

# Test Amazon Q CLI with MCP
timeout 13s bash -c "Q_LOG_LEVEL=trace q chat --no-interactive --trust-all-tools \"try to use the aws_docs___search tool to search for 's3', this is a test\"" 2>&1 | grep -E '(mcp servers initialized|error|failed)'

# Check the result
if [ $? -eq 124 ]; then
  echo -e "${RED}✗ Amazon Q CLI test timed out after 13 seconds${NC}"
else
  echo -e "${BLUE}Test completed. Check the output above for MCP initialization status.${NC}"
fi

echo -e "\n${BLUE}Recommendations:${NC}"
echo -e "${BLUE}---------------${NC}"
echo -e "1. Verify the MCP configuration format matches the documentation"
echo -e "2. Try restarting your terminal or computer"
echo -e "3. Run 'Q_LOG_LEVEL=trace q chat' for more detailed logs"

# Backup problematic MCP configuration file to restore Amazon Q functionality
mv ~/.aws/amazonq/mcp.json ~/.aws/amazonq/mcp-backup-buggy-did-not-load.json
echo -e "${YELLOW}! Backed up problematic MCP config to ~/.aws/amazonq/mcp-backup-buggy-did-not-load.json${NC}"
