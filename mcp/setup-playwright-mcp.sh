#!/bin/bash
# Setup script for Microsoft Playwright MCP server
# Following the Spilled Coffee Principle - anyone should be able to set this up easily

set -e

echo "Setting up Microsoft Playwright MCP server..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is required but not installed. Please install Node.js and npm first."
    exit 1
fi

# Install the official Microsoft Playwright MCP server
echo "Installing @microsoft/playwright-mcp..."
npm install -g @microsoft/playwright-mcp

# Verify installation
if ! command -v playwright-mcp &> /dev/null; then
    echo "Error: Installation failed. playwright-mcp command not found."
    exit 1
fi

# Get the installed version
PLAYWRIGHT_MCP_VERSION=$(npm list -g @microsoft/playwright-mcp | grep playwright-mcp | sed 's/.*@//')
echo "Successfully installed @microsoft/playwright-mcp version $PLAYWRIGHT_MCP_VERSION"

# Install Playwright browsers
echo "Installing Playwright browsers..."
npx playwright install

echo "Playwright MCP server setup complete!"
echo "You can now use the Playwright MCP server through the mcp/playwright-mcp-wrapper.sh script."
