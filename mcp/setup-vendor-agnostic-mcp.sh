#!/bin/bash
# Setup vendor-agnostic MCP configuration
# This script implements the vendor-agnostic MCP configuration pattern
# by moving .mcp.json to mcp/mcp.json and creating appropriate symlinks
#
# [NO-TEMPLATE-GENERATION]
# This script does NOT generate MCP configuration from templates.
# MCP configuration is a static JSON file (mcp/mcp.json) that is checked into git.
# The only dynamic aspect is creating symlinks for AI provider compatibility.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Source logging utilities
source "$SCRIPT_DIR/utils/mcp-logging.sh"

echo "Setting up vendor-agnostic MCP configuration..."

# Step 1: Move .mcp.json to mcp/mcp.json if it exists at root
if [ -f "$REPO_ROOT/.mcp.json" ] && [ ! -f "$REPO_ROOT/mcp/mcp.json" ]; then
    echo "Moving .mcp.json to vendor-agnostic location (mcp/mcp.json)..."
    mv "$REPO_ROOT/.mcp.json" "$REPO_ROOT/mcp/mcp.json"
elif [ -f "$REPO_ROOT/mcp/mcp.json" ]; then
    echo "MCP config already in vendor-agnostic location (mcp/mcp.json)"
else
    echo "ERROR: No MCP configuration file found (.mcp.json or mcp/mcp.json)"
    exit 1
fi

# Step 2: Create symlink for Claude Code compatibility
if [ ! -e "$REPO_ROOT/.mcp.json" ]; then
    echo "Creating symlink for Claude Code compatibility..."
    ln -s mcp/mcp.json "$REPO_ROOT/.mcp.json"
    echo "✓ Symlink created: .mcp.json → mcp/mcp.json"
elif [ -L "$REPO_ROOT/.mcp.json" ]; then
    echo "✓ Symlink already exists: .mcp.json → mcp/mcp.json"
else
    echo "ERROR: .mcp.json exists but is not a symlink"
    exit 1
fi

# Step 3: Document other MCP client configurations
echo ""
echo "Vendor-agnostic MCP setup complete!"
echo ""
echo "Current configuration:"
echo "- Canonical location: mcp/mcp.json"
echo "- Claude Code symlink: .mcp.json → mcp/mcp.json"
echo ""
echo "To add support for other MCP clients:"
echo "1. Investigate where the client looks for MCP configs"
echo "2. Add appropriate symlinks or configuration"
echo "3. Update this script to automate the setup"
echo ""
echo "Known MCP client config locations:"
echo "- Claude Code: .mcp.json (root directory)"
echo "- Amazon Q: Currently uses .mcp.json (same as Claude Code)"
echo "- Cursor: TBD (needs investigation)"
echo "- VSCode: TBD (needs investigation)"
echo ""
echo "Note: Amazon Q appears to use the same .mcp.json location as Claude Code,"
echo "making our vendor-agnostic approach immediately compatible with both clients."