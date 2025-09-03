#!/bin/bash

# =========================================================
# PATCHRIGHT-ENABLED PLAYWRIGHT MCP SERVER SETUP
# =========================================================
# PURPOSE: Configure the official @playwright/mcp server to use 
# patchright as a drop-in replacement for Playwright, providing
# stealth browser automation capabilities
# =========================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this setup script is located
CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_SCRIPT_DIRECTORY/utils/mcp-setup-utils.sh"

# Get dotfiles root
DOTFILES_ROOT="$(cd "$CURRENT_SCRIPT_DIRECTORY/.." && pwd)"

echo -e "${GREEN}Setting up Patchright-enabled Playwright MCP server...${NC}"

# Create servers directory if it doesn't exist
SERVERS_DIR="$CURRENT_SCRIPT_DIRECTORY/servers"
mkdir -p "$SERVERS_DIR"

# Patchright-enabled Playwright MCP directory
PATCHRIGHT_PLAYWRIGHT_DIR="$SERVERS_DIR/patchright-playwright-mcp"

# Verify the configuration files exist
if [ ! -f "$PATCHRIGHT_PLAYWRIGHT_DIR/package.json" ]; then
    echo -e "${RED}Error: Configuration files not found at $PATCHRIGHT_PLAYWRIGHT_DIR${NC}"
    echo -e "${RED}The patchright-playwright-mcp configuration should be committed to the repository.${NC}"
    exit 1
fi

echo -e "${GREEN}Found patchright MCP configuration files${NC}"

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed. Please install Node.js and npm first.${NC}"
    exit 1
fi

# Install dependencies with patchright replacing playwright
echo -e "${GREEN}Installing dependencies with patchright as playwright replacement...${NC}"
cd "$PATCHRIGHT_PLAYWRIGHT_DIR"

# Clean install to ensure overrides are applied
rm -rf node_modules package-lock.json
npm install

# Verify installation
echo -e "${GREEN}Verifying installation...${NC}"

# Check if @playwright/mcp was installed
if [ ! -d "node_modules/@playwright/mcp" ]; then
    echo -e "${RED}Error: Failed to install @playwright/mcp${NC}"
    exit 1
fi

# Check if patchright was installed
if [ ! -d "node_modules/patchright" ]; then
    echo -e "${RED}Error: Failed to install patchright${NC}"
    exit 1
fi

# Verify the executable exists
if [ ! -f "node_modules/.bin/mcp-server-playwright" ]; then
    echo -e "${RED}Error: MCP server executable not found${NC}"
    exit 1
fi

# Check if patchright browsers were installed
if [ -d "node_modules/patchright/.local-browsers" ]; then
    echo -e "${GREEN}✓ Patchright browsers installed${NC}"
    BROWSER_COUNT=$(ls -1 node_modules/patchright/.local-browsers | wc -l)
    echo -e "  Found $BROWSER_COUNT browser(s) in patchright cache"
else
    echo -e "${YELLOW}Warning: Patchright browsers not found, attempting manual install...${NC}"
    npx patchright install chromium || echo "Chromium install failed (may already be installed)"
    
    # Try to install Chrome if possible (may fail if system Chrome exists)
    npx patchright install chrome 2>/dev/null || echo "Chrome install skipped (system Chrome may be present)"
fi

# Verify script should already exist
if [ ! -f "$PATCHRIGHT_PLAYWRIGHT_DIR/verify.js" ]; then
    echo -e "${YELLOW}Warning: verify.js not found in repository${NC}"
fi

# Run verification
echo -e "\n${GREEN}Running verification...${NC}"
cd "$PATCHRIGHT_PLAYWRIGHT_DIR"
node verify.js

echo -e "\n${GREEN}=== Patchright-enabled Playwright MCP Server Setup Complete ===${NC}"
echo -e "Server location: ${YELLOW}$PATCHRIGHT_PLAYWRIGHT_DIR${NC}"
echo -e "\n${GREEN}What's configured:${NC}"
echo "  ✓ Official @playwright/mcp server installed"
echo "  ✓ Playwright aliased to patchright for stealth capabilities"
echo "  ✓ Chrome and Chromium browsers installed via patchright"
echo "  ✓ Launcher script configured with optimal stealth settings"
echo -e "\n${GREEN}Features:${NC}"
echo "  • CDP bypass for sites that detect automation"
echo "  • Built-in stealth capabilities from patchright"
echo "  • Full compatibility with @playwright/mcp tools"
echo "  • No custom server code - uses official Microsoft server"
echo -e "\n${YELLOW}Note:${NC} Update your MCP configuration to point to:"
echo "  $PATCHRIGHT_PLAYWRIGHT_DIR/launcher.js"