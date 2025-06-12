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

# Get current project or prompt to set one
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -z "$CURRENT_PROJECT" ]; then
    echo -e "${YELLOW}No default project set.${NC}"
    echo -e "${BLUE}Available projects:${NC}"
    gcloud projects list --format="table(projectId,name,lifecycleState)" --filter="lifecycleState:ACTIVE"
    echo ""
    echo -e "${BLUE}📋 Please select a Google Cloud project for Google Drive MCP setup${NC}"
    echo -e "${YELLOW}👆 From the list above, find your project and copy its PROJECT_ID${NC}"
    echo -e "${GREEN}💡 Recommended: gdrive-mcp-shared-acces (if available)${NC}"
    echo ""
    echo -e "${BLUE}⏳ WAITING FOR YOUR INPUT BELOW ⏳${NC}"
    echo -e "${YELLOW}The script is paused and waiting for you to type a project name${NC}"
    echo ""
    echo -e "${GREEN}>>> TYPE YOUR PROJECT ID HERE AND PRESS ENTER <<<${NC}"
    read -p "Project ID: " PROJECT_ID
    
    if [ -z "$PROJECT_ID" ]; then
        # Create new project
        echo -e "${BLUE}Creating new project...${NC}"
        PROJECT_ID="gdrive-mcp-$(date +%s)"
        PROJECT_NAME="Google Drive MCP Project"
        
        gcloud projects create "$PROJECT_ID" --name="$PROJECT_NAME"
        echo -e "${GREEN}✓ Created project: $PROJECT_ID${NC}"
        
        # Enable billing if needed (projects need billing for some APIs)
        echo -e "${YELLOW}Note: You may need to enable billing for this project${NC}"
        echo "Visit: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
    fi
    
    # Set as default project
    gcloud config set project "$PROJECT_ID"
    echo -e "${GREEN}✓ Set default project to: $PROJECT_ID${NC}"
else
    PROJECT_ID="$CURRENT_PROJECT"
    echo -e "${GREEN}Using current project: $PROJECT_ID${NC}"
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

# Try to get OAuth brand info
BRAND_INFO=$(gcloud alpha iap oauth-brands list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null | head -n1 || echo "")

if [ -z "$BRAND_INFO" ]; then
    echo -e "${YELLOW}OAuth consent screen not configured${NC}"
    echo -e "${BLUE}Opening Google Cloud Console for consent screen setup...${NC}"
    echo ""
    echo "Please complete these steps in the browser:"
    echo "1. Set Application name: 'Google Drive MCP Server'"
    echo "2. Add your email ($ACTIVE_ACCOUNT) as support email"
    echo "3. Add scope: https://www.googleapis.com/auth/drive.readonly"
    echo "4. Save and continue through all steps"
    echo "5. Return here when complete"
    echo ""
    
    # Open consent screen configuration
    if command -v open &> /dev/null; then
        open "https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
    else
        echo "Open this URL: https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
    fi
    
    read -p "Press Enter after configuring the consent screen..."
    
    # Verify consent screen was created
    BRAND_INFO=$(gcloud alpha iap oauth-brands list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null | head -n1 || echo "")
    if [ -z "$BRAND_INFO" ]; then
        echo -e "${RED}Consent screen setup incomplete${NC}"
        exit 1
    fi
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
echo "Please complete these steps in the browser:"
echo "1. Click 'Create Credentials' > 'OAuth client ID'"
echo "2. Choose 'Desktop application'"
echo "3. Name it: $CLIENT_NAME"
echo "4. Click 'Create'"
echo "5. Download the JSON file"
echo "6. Save it as: $CREDENTIALS_DIR/credentials.json"
echo ""

if command -v open &> /dev/null; then
    open "https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
elif command -v xdg-open &> /dev/null; then
    xdg-open "https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
else
    echo "Open this URL: https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
fi

read -p "Press Enter after downloading and saving the credentials file..."

# Verify credentials file exists and has correct structure
if [ ! -f "$CREDENTIALS_DIR/credentials.json" ]; then
    echo -e "${RED}Credentials file not found at $CREDENTIALS_DIR/credentials.json${NC}"
    exit 1
fi

# Basic validation of credentials file
if ! grep -q "client_id" "$CREDENTIALS_DIR/credentials.json" || ! grep -q "client_secret" "$CREDENTIALS_DIR/credentials.json"; then
    echo -e "${RED}Invalid credentials file format${NC}"
    echo "Expected JSON with client_id and client_secret fields"
    exit 1
fi

echo -e "${GREEN}✓ OAuth credentials configured successfully!${NC}"
echo -e "${BLUE}Credentials saved to: $CREDENTIALS_DIR/credentials.json${NC}"
echo ""
echo -e "${GREEN}Setup complete! Next steps:${NC}"
echo "1. Run the main Google Drive MCP setup: ./setup-gdrive-mcp.sh"
echo "2. Test with Amazon Q: q chat"
echo ""
echo -e "${BLUE}Project details:${NC}"
echo "Project ID: $PROJECT_ID"
echo "Client Name: $CLIENT_NAME"
echo "Credentials: $CREDENTIALS_DIR/credentials.json"
