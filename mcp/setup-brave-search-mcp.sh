#!/bin/bash
# Brave Search MCP Server Setup Script

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
source "$SCRIPT_DIR/utils/mcp-setup-utils.sh"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Setting up Brave Search MCP server..."

# Get repository root
REPO_ROOT=$(get_repo_root)

# Update the secrets template
update_secrets_template "$REPO_ROOT" "BRAVE_API_KEY" "BRAVE SEARCH API CREDENTIALS" "Get API key from: https://api.search.brave.com/app/keys" 'export BRAVE_API_KEY="your_api_key"'

# Check for required secrets
if [[ -z "$BRAVE_API_KEY" ]]; then
    echo -e "${YELLOW}⚠️  BRAVE_API_KEY not found in environment${NC}"
    echo "Please add to ~/.bash_secrets:"
    echo '  export BRAVE_API_KEY="your_api_key"'
    echo ""
    echo "Get your API key from: https://api.search.brave.com/app/keys"
fi

echo -e "${GREEN}✓ Brave Search MCP server setup complete!${NC}"