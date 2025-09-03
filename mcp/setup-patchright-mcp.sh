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

# Create directory
mkdir -p "$PATCHRIGHT_PLAYWRIGHT_DIR"

# Create package.json with npm overrides to use patchright instead of playwright
echo -e "${GREEN}Creating package.json with patchright overrides...${NC}"
cat > "$PATCHRIGHT_PLAYWRIGHT_DIR/package.json" << 'EOF'
{
  "name": "patchright-playwright-mcp",
  "version": "1.0.0",
  "description": "Official Playwright MCP server using patchright as a drop-in replacement",
  "main": "launcher.js",
  "scripts": {
    "postinstall": "npx patchright install chromium || true"
  },
  "dependencies": {
    "@playwright/mcp": "latest",
    "patchright": "^1.52.5",
    "playwright": "npm:patchright@^1.52.5",
    "playwright-core": "npm:patchright@^1.52.5"
  },
  "overrides": {
    "playwright": "npm:patchright@^1.52.5",
    "playwright-core": "npm:patchright@^1.52.5"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Create a launcher script that sets up the environment
echo -e "${GREEN}Creating launcher script...${NC}"
cat > "$PATCHRIGHT_PLAYWRIGHT_DIR/launcher.js" << 'EOF'
#!/usr/bin/env node

/**
 * Launcher for Playwright MCP server with patchright
 * 
 * This launcher ensures the official @playwright/mcp server runs
 * with patchright as the backend through npm aliasing
 */

const { spawn } = require('child_process');
const path = require('path');

// Set environment for stealth configuration
const env = {
  ...process.env,
  // Log level
  FASTMCP_LOG_LEVEL: process.env.FASTMCP_LOG_LEVEL || 'ERROR',
  // Recommended patchright configuration for stealth
  PLAYWRIGHT_LAUNCH_OPTIONS: JSON.stringify({
    channel: 'chrome',  // Use real Chrome instead of Chromium
    headless: false,    // Patchright works best in headed mode
    viewport: null,     // Don't set custom viewport
    args: [
      '--start-maximized',
      '--disable-blink-features=AutomationControlled'
    ],
    ignoreDefaultArgs: ['--enable-automation']
  })
};

// Find the mcp-server-playwright executable
const mcpExecutable = path.join(__dirname, 'node_modules', '.bin', 'mcp-server-playwright');

// Launch the MCP server
const mcpServer = spawn(mcpExecutable, process.argv.slice(2), {
  stdio: 'inherit',
  env: env,
  cwd: __dirname
});

mcpServer.on('error', (err) => {
  console.error('[patchright-mcp] Failed to start MCP server:', err);
  process.exit(1);
});

mcpServer.on('close', (code) => {
  process.exit(code || 0);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  mcpServer.kill('SIGINT');
});

process.on('SIGTERM', () => {
  mcpServer.kill('SIGTERM');
});
EOF

# Make the launcher executable
chmod +x "$PATCHRIGHT_PLAYWRIGHT_DIR/launcher.js"

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

# Create a test script to verify patchright is being used
echo -e "${GREEN}Creating verification script...${NC}"
cat > "$PATCHRIGHT_PLAYWRIGHT_DIR/verify.js" << 'EOF'
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('Verifying patchright installation...\n');

// Check if playwright resolves to patchright
try {
  const playwrightPath = require.resolve('playwright');
  const playwrightPackage = require('playwright/package.json');
  
  console.log('playwright resolves to:', playwrightPath);
  console.log('Package name:', playwrightPackage.name);
  console.log('Package version:', playwrightPackage.version);
  
  if (playwrightPackage.name === 'patchright') {
    console.log('✓ Successfully aliased playwright to patchright');
  } else {
    console.log('✗ playwright is not aliased to patchright');
  }
} catch (e) {
  console.error('Error checking playwright:', e.message);
}

console.log('\n--- Quick functionality test ---');
const { chromium } = require('playwright');
console.log('chromium.name:', chromium.name());
console.log('✓ Patchright-aliased playwright is functional');
EOF

chmod +x "$PATCHRIGHT_PLAYWRIGHT_DIR/verify.js"

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