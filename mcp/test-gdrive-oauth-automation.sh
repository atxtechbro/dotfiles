#!/bin/bash

# =========================================================
# GOOGLE DRIVE OAUTH AUTOMATION TEST
# =========================================================
# PURPOSE: Test the automated OAuth setup flow
# This script simulates the setup process without actually running it
# =========================================================

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing Google Drive OAuth automation setup...${NC}"

# Check if all required scripts exist
SCRIPT_DIR="$(dirname "$0")"
UTILS_DIR="../utils"

echo -e "${BLUE}Checking required files...${NC}"

# Check OAuth setup script
if [ -f "$SCRIPT_DIR/setup-gdrive-oauth.sh" ]; then
    echo -e "${GREEN}✓ OAuth setup script found${NC}"
else
    echo -e "${RED}✗ OAuth setup script missing: $SCRIPT_DIR/setup-gdrive-oauth.sh${NC}"
    exit 1
fi

# Check gcloud installation utility
if [ -f "$UTILS_DIR/install-gcloud.sh" ]; then
    echo -e "${GREEN}✓ gcloud installation utility found${NC}"
else
    echo -e "${RED}✗ gcloud installation utility missing: $UTILS_DIR/install-gcloud.sh${NC}"
    exit 1
fi

# Check main setup script
if [ -f "$SCRIPT_DIR/setup-gdrive-mcp.sh" ]; then
    echo -e "${GREEN}✓ Main MCP setup script found${NC}"
else
    echo -e "${RED}✗ Main MCP setup script missing: $SCRIPT_DIR/setup-gdrive-mcp.sh${NC}"
    exit 1
fi

# Check if main setup script calls OAuth automation
if grep -q "setup-gdrive-oauth.sh" "$SCRIPT_DIR/setup-gdrive-mcp.sh"; then
    echo -e "${GREEN}✓ Main setup script integrated with OAuth automation${NC}"
else
    echo -e "${RED}✗ Main setup script not integrated with OAuth automation${NC}"
    exit 1
fi

# Check script permissions
if [ -x "$SCRIPT_DIR/setup-gdrive-oauth.sh" ]; then
    echo -e "${GREEN}✓ OAuth setup script is executable${NC}"
else
    echo -e "${YELLOW}⚠ OAuth setup script needs execute permission${NC}"
    chmod +x "$SCRIPT_DIR/setup-gdrive-oauth.sh"
    echo -e "${GREEN}✓ Fixed execute permission${NC}"
fi

if [ -x "$UTILS_DIR/install-gcloud.sh" ]; then
    echo -e "${GREEN}✓ gcloud installation utility is executable${NC}"
else
    echo -e "${YELLOW}⚠ gcloud installation utility needs execute permission${NC}"
    chmod +x "$UTILS_DIR/install-gcloud.sh"
    echo -e "${GREEN}✓ Fixed execute permission${NC}"
fi

echo -e "\n${GREEN}✅ All automation components are ready!${NC}"
echo -e "\n${BLUE}Automation Flow Summary:${NC}"
echo "1. Run: ./setup-gdrive-mcp.sh"
echo "2. If no credentials found, automatically runs: ./setup-gdrive-oauth.sh"
echo "3. OAuth script checks for gcloud, installs if missing via: ../utils/install-gcloud.sh"
echo "4. OAuth script guides through Google Cloud setup with minimal browser interaction"
echo "5. Main script continues with Docker authentication and MCP server setup"
echo ""
echo -e "${YELLOW}What you'll still need to provide:${NC}"
echo "- Google account authentication (gcloud auth login)"
echo "- OAuth consent screen configuration (browser)"
echo "- OAuth client ID creation (browser)"
echo ""
echo -e "${GREEN}Ready to test! Run: ./setup-gdrive-mcp.sh${NC}"
