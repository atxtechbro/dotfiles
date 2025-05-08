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

echo -e "\n${BLUE}Checking environment...${NC}"
echo -e "${BLUE}----------------------${NC}"

# Check if the GitHub token is set
if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  echo -e "${GREEN}✓ GitHub token is set:${NC} ${GITHUB_PERSONAL_ACCESS_TOKEN:0:5}..."
  
  # Validate token format
  if [[ "$GITHUB_PERSONAL_ACCESS_TOKEN" == ghp_* ]]; then
    echo -e "${GREEN}✓ GitHub token has correct prefix (ghp_)${NC}"
  else
    echo -e "${RED}✗ GitHub token does not have expected prefix 'ghp_'${NC}"
  fi
else
  echo -e "${RED}✗ GitHub token is not set${NC}"
  
  # Check if token is in secrets file
  if [ -f "$HOME/.bash_secrets" ]; then
    if grep -q "GITHUB_PERSONAL_ACCESS_TOKEN=" "$HOME/.bash_secrets"; then
      echo -e "${YELLOW}! GitHub token found in .bash_secrets but not exported to environment${NC}"
      echo -e "${YELLOW}! Try sourcing .bash_secrets before running this script${NC}"
    else
      echo -e "${RED}✗ No GitHub token found in .bash_secrets${NC}"
    fi
  else
    echo -e "${RED}✗ No .bash_secrets file found${NC}"
  fi
fi

# Check if Docker is installed
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✓ Docker is installed:${NC} $(docker --version)"
  
  # Check if user can run Docker without sudo
  if docker info &>/dev/null; then
    echo -e "${GREEN}✓ User can run Docker without sudo${NC}"
  else
    echo -e "${YELLOW}! User may need sudo to run Docker${NC}"
  fi
else
  echo -e "${RED}✗ Docker is not installed${NC}"
fi

echo -e "\n${BLUE}Testing GitHub MCP server...${NC}"
echo -e "${BLUE}--------------------------${NC}"

# Test the GitHub MCP server directly with Docker
echo -e "${BLUE}Testing GitHub MCP server with Docker...${NC}"
echo -e "${YELLOW}(This will timeout after 13 seconds if stuck)${NC}"

# Create a temporary file for the test input
TEST_INPUT=$(mktemp)
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' > "$TEST_INPUT"

# Run the test with a timeout
timeout 13s docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" ghcr.io/github/github-mcp-server stdio < "$TEST_INPUT"
TEST_RESULT=$?

# Check the result
if [ $TEST_RESULT -eq 124 ]; then
  echo -e "${RED}✗ Test timed out after 13 seconds${NC}"
elif [ $TEST_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ GitHub MCP server responded successfully${NC}"
else
  echo -e "${RED}✗ GitHub MCP server test failed with exit code ${TEST_RESULT}${NC}"
fi

# Clean up
rm -f "$TEST_INPUT"

echo -e "\n${BLUE}Testing Amazon Q CLI with MCP...${NC}"
echo -e "${BLUE}----------------------------${NC}"
echo -e "${YELLOW}(This will timeout after 13 seconds if stuck)${NC}"

# Test Amazon Q CLI with MCP
timeout 13s bash -c "Q_LOG_LEVEL=trace q chat --no-interactive --trust-all-tools \"try to use the github___search_repositories tool to search for 'amazon-q', this is a test\"" 2>&1 | grep -E '(mcp servers initialized|error|failed)'

# Check the result
if [ $? -eq 124 ]; then
  echo -e "${RED}✗ Amazon Q CLI test timed out after 13 seconds${NC}"
else
  echo -e "${BLUE}Test completed. Check the output above for MCP initialization status.${NC}"
fi

echo -e "\n${BLUE}Recommendations:${NC}"
echo -e "${BLUE}---------------${NC}"
echo -e "1. Ensure your GitHub token has the correct permissions"
echo -e "2. Try running 'docker pull ghcr.io/github/github-mcp-server' to ensure the image is available"
echo -e "3. Check your Docker installation and permissions"
echo -e "4. Verify the MCP configuration format matches the documentation"
echo -e "5. Try restarting your terminal or computer"
echo -e "6. Run 'Q_LOG_LEVEL=trace q chat' for more detailed logs"
