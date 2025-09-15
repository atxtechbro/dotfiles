#!/bin/bash

# =========================================================
# GOOGLE DRIVE CREDENTIALS SETUP SCRIPT
# =========================================================
# PURPOSE: Automate the complete Google Drive OAuth setup process
# Following the "Spilled Coffee Principle" - fully reproducible setup
# This script handles everything from OAuth flow to Docker volume setup
# =========================================================

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$0")"
CREDENTIALS_DIR="$HOME/.config/gdrive"
TEMP_DIR="$HOME/tmp/gdrive-oauth"

echo -e "${BLUE}🔧 Setting up Google Drive MCP credentials...${NC}"

# Create necessary directories
mkdir -p "$CREDENTIALS_DIR"
mkdir -p "$TEMP_DIR"

# Check if credentials already exist
if [ -f "$CREDENTIALS_DIR/credentials.json" ]; then
    echo -e "${YELLOW}⚠️  Credentials already exist at $CREDENTIALS_DIR/credentials.json${NC}"
    read -p "Do you want to regenerate them? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ Using existing credentials${NC}"
        SKIP_OAUTH=true
    fi
fi

if [ "$SKIP_OAUTH" != "true" ]; then
    # Check if we have the base credentials file
    if [ ! -f "$TEMP_DIR/credentials.json" ]; then
        echo -e "${RED}❌ Base credentials.json not found at $TEMP_DIR/credentials.json${NC}"
        echo -e "${YELLOW}You need to create OAuth credentials first:${NC}"
        echo "1. Go to: https://console.cloud.google.com/apis/credentials"
        echo "2. Create OAuth 2.0 Client ID (Desktop application)"
        echo "3. Download the JSON file as $TEMP_DIR/credentials.json"
        echo "4. Run this script again"
        exit 1
    fi

    # Generate OAuth URL
    CLIENT_ID=$(jq -r '.installed.client_id' "$TEMP_DIR/credentials.json")
    REDIRECT_URI="http://localhost"
    SCOPE="https://www.googleapis.com/auth/drive.readonly"
    OAUTH_URL="https://accounts.google.com/o/oauth2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=${SCOPE}&response_type=code&access_type=offline&prompt=consent"

    echo -e "${BLUE}🔗 OAuth Authorization Required${NC}"
    echo ""
    echo "1. Open this URL in your browser:"
    echo "$OAUTH_URL"
    echo ""
    echo "2. Sign in and grant permissions"
    echo "3. Copy the entire callback URL (starts with http://localhost/?code=...)"
    echo ""
    read -p "Paste the full callback URL here: " CALLBACK_URL

    # Extract authorization code
    AUTH_CODE=$(echo "$CALLBACK_URL" | sed -n 's/.*code=\([^&]*\).*/\1/p')
    if [ -z "$AUTH_CODE" ]; then
        echo -e "${RED}❌ Could not extract authorization code${NC}"
        exit 1
    fi

    echo -e "${BLUE}🔄 Exchanging authorization code for tokens...${NC}"

    # Extract credentials
    CLIENT_SECRET=$(jq -r '.installed.client_secret' "$TEMP_DIR/credentials.json")

    # Exchange for tokens
    RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=$CLIENT_ID" \
      -d "client_secret=$CLIENT_SECRET" \
      -d "code=$AUTH_CODE" \
      -d "grant_type=authorization_code" \
      -d "redirect_uri=$REDIRECT_URI")

    # Extract tokens
    REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refresh_token // empty')
    ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token // empty')

    if [ -z "$REFRESH_TOKEN" ]; then
        echo -e "${RED}❌ Failed to get refresh token${NC}"
        echo "Response: $RESPONSE"
        exit 1
    fi

    # Create complete credentials file
    COMPLETE_CREDENTIALS=$(jq --arg refresh_token "$REFRESH_TOKEN" \
                              --arg access_token "$ACCESS_TOKEN" \
                              '. + {
                                "refresh_token": $refresh_token,
                                "access_token": $access_token,
                                "token_type": "Bearer"
                              }' "$TEMP_DIR/credentials.json")

    # Save credentials
    echo "$COMPLETE_CREDENTIALS" > "$CREDENTIALS_DIR/credentials.json"
    chmod 600 "$CREDENTIALS_DIR/credentials.json"

    echo -e "${GREEN}✓ Credentials saved to $CREDENTIALS_DIR/credentials.json${NC}"
fi

# Update .bash_secrets if needed
SECRETS_FILE="$HOME/.bash_secrets"
if [ -f "$SECRETS_FILE" ]; then
    if ! grep -q "GDRIVE_CREDENTIALS_PATH" "$SECRETS_FILE"; then
        echo -e "${BLUE}📝 Adding GDRIVE_CREDENTIALS_PATH to .bash_secrets...${NC}"
        cat >> "$SECRETS_FILE" << EOF

# ==== GOOGLE DRIVE API CREDENTIALS ====
# OAuth2 credentials for Google Drive MCP server
export GDRIVE_CREDENTIALS_PATH="$CREDENTIALS_DIR/credentials.json"
EOF
        echo -e "${GREEN}✓ Updated .bash_secrets${NC}"
    else
        echo -e "${GREEN}✓ GDRIVE_CREDENTIALS_PATH already in .bash_secrets${NC}"
    fi
fi

# Setup Docker volume
echo -e "${BLUE}🐳 Setting up Docker volume for MCP server...${NC}"

# Check if Docker volume exists
if ! docker volume ls | grep -q "mcp-gdrive"; then
    docker volume create mcp-gdrive
    echo -e "${GREEN}✓ Created Docker volume: mcp-gdrive${NC}"
fi

# Copy credentials to Docker volume
docker run --rm \
  -v mcp-gdrive:/gdrive-server \
  -v "$CREDENTIALS_DIR:/host-credentials:ro" \
  alpine cp /host-credentials/credentials.json /gdrive-server/credentials.json

echo -e "${GREEN}✓ Credentials copied to Docker volume${NC}"

# Test the setup
echo -e "${BLUE}🧪 Testing MCP server setup...${NC}"
if docker run --rm \
  -v mcp-gdrive:/gdrive-server \
  -e GDRIVE_CREDENTIALS_PATH=/gdrive-server/credentials.json \
  mcp/gdrive echo "Test successful" 2>/dev/null; then
    echo -e "${GREEN}✅ Google Drive MCP server setup complete!${NC}"
else
    echo -e "${RED}❌ MCP server test failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "Your Google Drive MCP server is now ready to use."
echo "Restart Amazon Q to pick up the changes."
