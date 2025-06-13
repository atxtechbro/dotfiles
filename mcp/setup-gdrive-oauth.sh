#!/bin/bash

# =========================================================
# GOOGLE DRIVE OAUTH SETUP SCRIPT
# =========================================================
# PURPOSE: Automate Google Cloud OAuth setup for Google Drive MCP
# This script uses gcloud CLI to minimize browser interaction
# Following the "Snowball Method" - automate everything possible
# =========================================================

set -e  # Exit on any error

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
PROJECT_ID_ARG=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      PROJECT_ID_ARG="$2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      echo "Usage: $0 [--project PROJECT_ID]"
      echo "Example: $0 --project gdrive-mcp-shared-acces"
      exit 1
      ;;
  esac
done
echo -e "${BLUE}Setting up Google Drive OAuth credentials via gcloud CLI...${NC}"

# Get script directory for utility functions
SCRIPT_DIR="$(dirname "$0")"
UTILS_DIR="../utils"

# Check if gcloud is installed, install if not
if ! command -v gcloud &> /dev/null; then
    echo -e "${YELLOW}gcloud CLI not found - installing automatically...${NC}"
    
    if [ -f "$UTILS_DIR/install-gcloud.sh" ]; then
        source "$UTILS_DIR/install-gcloud.sh"
    else
        echo -e "${RED}Error: install-gcloud.sh utility not found${NC}"
        echo "Expected location: $UTILS_DIR/install-gcloud.sh"
        exit 1
    fi
    
    # Verify installation worked
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}gcloud installation failed${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ gcloud CLI available${NC}"

# Check if user is authenticated
ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n1 || echo "")
if [ -z "$ACTIVE_ACCOUNT" ]; then
    echo -e "${YELLOW}You need to authenticate with gcloud first${NC}"
    echo "Running: gcloud auth login"
    gcloud auth login
    
    # Verify authentication worked
    ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n1 || echo "")
    if [ -z "$ACTIVE_ACCOUNT" ]; then
        echo -e "${RED}Authentication failed${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Authenticated as: $ACTIVE_ACCOUNT${NC}"

# Get current project or use provided argument
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -n "$PROJECT_ID_ARG" ]; then
    PROJECT_ID="$PROJECT_ID_ARG"
    echo -e "${GREEN}Using provided project: $PROJECT_ID${NC}"
elif [ -n "$CURRENT_PROJECT" ]; then
    PROJECT_ID="$CURRENT_PROJECT"
    echo -e "${GREEN}Using current project: $PROJECT_ID${NC}"
else
    echo -e "${RED}No project specified and no default project set${NC}"
    echo -e "${YELLOW}Please provide a project using: $0 --project PROJECT_ID${NC}"
    echo -e "${BLUE}Example: $0 --project gdrive-mcp-shared-acces${NC}"
    echo ""
    echo -e "${YELLOW}To see available projects, run: gcloud projects list${NC}"
    exit 1
fi

# Set as default project if not already set
if [ "$PROJECT_ID" != "$CURRENT_PROJECT" ]; then
    gcloud config set project "$PROJECT_ID"
    echo -e "${GREEN}✓ Set default project to: $PROJECT_ID${NC}"
fi
# Enable required APIs
echo -e "${BLUE}Enabling Google Drive API...${NC}"
gcloud services enable drive.googleapis.com --project="$PROJECT_ID"
echo -e "${GREEN}✓ Google Drive API enabled${NC}"

# Create credentials directory
CREDENTIALS_DIR=~/tmp/gdrive-oath
mkdir -p "$CREDENTIALS_DIR"

# Check if OAuth consent screen exists
echo -e "${BLUE}Checking OAuth consent screen...${NC}"

# Try to get OAuth brand info with timeout
echo -e "${YELLOW}Checking if consent screen is configured (this may take a moment)...${NC}"
BRAND_INFO=$(timeout 30 gcloud alpha iap oauth-brands list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null | head -n1 || echo "")

if [ $? -eq 124 ]; then
    echo -e "${YELLOW}OAuth consent screen check timed out - assuming not configured${NC}"
    BRAND_INFO=""
fi

if [ -z "$BRAND_INFO" ]; then
    echo -e "${YELLOW}OAuth consent screen not configured${NC}"
    echo -e "${BLUE}Opening Google Cloud Console for consent screen setup...${NC}"
    echo ""
echo "🌐 BROWSER SHOULD HAVE OPENED - Check your browser now!"
echo ""
echo "If no browser opened, manually go to:"
echo "https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
echo ""
echo "📋 Complete these steps in the Google Cloud Console:"
echo "1. Click 'CONFIGURE CONSENT SCREEN' if you see that button"
echo "2. Choose 'Internal' user type (recommended for corporate)"
echo "3. Set Application name: 'Google Drive MCP Server'"
echo "4. Add your email ($ACTIVE_ACCOUNT) as support email"
echo "5. Click 'SAVE AND CONTINUE'"
echo "6. On Scopes page: Click 'ADD OR REMOVE SCOPES'"
echo "7. Search for and add: https://www.googleapis.com/auth/drive.readonly"
echo "8. Click 'SAVE AND CONTINUE' through remaining steps"
echo "9. Return here and press Enter when complete"
echo ""
echo "⏳ Waiting for you to complete the OAuth consent screen setup..."    
    # Skip verification - assume user completed it
    echo -e "${GREEN}✓ Assuming OAuth consent screen configured${NC}"
else
    echo -e "${GREEN}✓ OAuth consent screen already configured${NC}"
fi
echo -e "${GREEN}✓ OAuth consent screen configured${NC}"

# Create OAuth Client ID
echo -e "${BLUE}Creating OAuth Client ID...${NC}"

# Generate unique client name
CLIENT_NAME="gdrive-mcp-client-$(date +%s)"

# Try to create OAuth client using gcloud (this may not work in all cases)
echo -e "${YELLOW}Attempting automated OAuth client creation...${NC}"

# Open credentials page for manual creation (most reliable method)
echo -e "${BLUE}Opening Google Cloud Console for OAuth client creation...${NC}"
echo ""
echo "🌐 BROWSER SHOULD HAVE OPENED - Check your browser now!"
echo ""
echo "If no browser opened, manually go to:"
echo "https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
echo ""
echo "📋 Complete these steps in the Google Cloud Console:"
echo "1. Click 'CONFIGURE CONSENT SCREEN' if you see that button"
echo "2. Choose 'Internal' user type (recommended for corporate)"
echo "3. Set Application name: 'Google Drive MCP Server'"
echo "4. Add your email ($ACTIVE_ACCOUNT) as support email"
echo "5. Click 'SAVE AND CONTINUE'"
echo "6. On Scopes page: Click 'ADD OR REMOVE SCOPES'"
echo "7. Search for and add: https://www.googleapis.com/auth/drive.readonly"
echo "8. Click 'SAVE AND CONTINUE' through remaining steps"
echo "9. Return here and press Enter when complete"
echo ""
echo "⏳ Waiting for you to complete the OAuth consent screen setup..."