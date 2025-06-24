#!/bin/bash

# =========================================================
# MCP CONFIG VERIFICATION
# =========================================================
# PURPOSE: Verify MCP configuration matches WORK_MACHINE setting
# =========================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 MCP Configuration Verification"
echo "================================="

# Check current machine type
echo -e "\n📋 Current Settings:"
echo "WORK_MACHINE=${WORK_MACHINE:-not set}"

# Check mcp.json
echo -e "\n📄 Checking mcp.json:"
if [[ -f mcp/mcp.json ]]; then
    if grep -q "atlassian\|gitlab" mcp/mcp.json; then
        if [[ "${WORK_MACHINE:-false}" == "true" ]]; then
            echo -e "${GREEN}✓ Work-only servers found (expected on work machine)${NC}"
        else
            echo -e "${RED}✗ Work-only servers found (should be hidden on personal machine)${NC}"
            echo "  Run: ./mcp/generate-mcp-config.sh to fix"
        fi
    else
        if [[ "${WORK_MACHINE:-false}" == "true" ]]; then
            echo -e "${RED}✗ Work-only servers missing (should be visible on work machine)${NC}"
            echo "  Run: ./mcp/generate-mcp-config.sh to fix"
        else
            echo -e "${GREEN}✓ Work-only servers hidden (expected on personal machine)${NC}"
        fi
    fi
else
    echo -e "${RED}✗ mcp.json not found${NC}"
fi

# Check Claude Code config
echo -e "\n📄 Checking Claude Code config:"
CLAUDE_CONFIG="$HOME/.config/claude-cli-nodejs/mcp.json"
if [[ -f "$CLAUDE_CONFIG" ]]; then
    if grep -q "atlassian\|gitlab" "$CLAUDE_CONFIG"; then
        if [[ "${WORK_MACHINE:-false}" == "true" ]]; then
            echo -e "${GREEN}✓ Work-only servers in Claude config (expected)${NC}"
        else
            echo -e "${YELLOW}⚠ Work-only servers in Claude config (run generate-mcp-config.sh)${NC}"
        fi
    else
        if [[ "${WORK_MACHINE:-false}" == "true" ]]; then
            echo -e "${YELLOW}⚠ Work-only servers missing from Claude config${NC}"
        else
            echo -e "${GREEN}✓ Work-only servers hidden in Claude config (expected)${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠ Claude Code config not found (normal if not installed)${NC}"
fi

echo -e "\n✅ Verification complete!"