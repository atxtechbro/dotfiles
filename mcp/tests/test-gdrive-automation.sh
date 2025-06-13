#!/bin/bash

# =========================================================
# TEST GOOGLE DRIVE AUTOMATION
# =========================================================
# PURPOSE: Validate that the hardened automation works correctly
# Following the "Spilled Coffee Principle" - test reproducibility
# =========================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "🧪 Testing Google Drive MCP automation..."

# Test 1: Check if setup script exists and is executable
if [[ -x "../setup-gdrive-oauth-complete.sh" ]]; then
    echo -e "${GREEN}✓ Setup script exists and is executable${NC}"
else
    echo -e "${RED}❌ Setup script missing or not executable${NC}"
    exit 1
fi

# Test 2: Check if OAuth helper utilities exist
if [[ -f "../utils/oauth-helper.sh" ]]; then
    echo -e "${GREEN}✓ OAuth helper utilities exist${NC}"
    
    # Test helper functions
    source ../utils/oauth-helper.sh
    
    # Test URL generation
    TEST_URL=$(generate_google_oauth_url "test-client-id" "test-scope")
    if [[ "$TEST_URL" == *"test-client-id"* ]] && [[ "$TEST_URL" == *"test-scope"* ]]; then
        echo -e "${GREEN}✓ OAuth URL generation works${NC}"
    else
        echo -e "${RED}❌ OAuth URL generation failed${NC}"
        exit 1
    fi
    
    # Test auth code extraction
    TEST_CODE=$(extract_auth_code "http://localhost/?code=test123&scope=test")
    if [[ "$TEST_CODE" == "test123" ]]; then
        echo -e "${GREEN}✓ Auth code extraction works${NC}"
    else
        echo -e "${RED}❌ Auth code extraction failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ OAuth helper utilities missing${NC}"
    exit 1
fi

# Test 3: Check if documentation exists
if [[ -f "../docs/gdrive-setup-guide.md" ]]; then
    echo -e "${GREEN}✓ Documentation exists${NC}"
else
    echo -e "${RED}❌ Documentation missing${NC}"
    exit 1
fi

# Test 4: Check if main setup.sh includes gdrive setup
if grep -q "setup-gdrive-oauth-complete.sh" "../../setup.sh"; then
    echo -e "${GREEN}✓ Main setup.sh includes gdrive setup${NC}"
else
    echo -e "${RED}❌ Main setup.sh missing gdrive integration${NC}"
    exit 1
fi

# Test 5: Validate script syntax
if bash -n ../setup-gdrive-oauth-complete.sh; then
    echo -e "${GREEN}✓ Setup script syntax is valid${NC}"
else
    echo -e "${RED}❌ Setup script has syntax errors${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 All automation tests passed!${NC}"
echo "The hardened Google Drive MCP setup is ready for production use."
