#!/bin/bash
# Amazon Q Trust Setup Script
# Sets up trusted tools for Amazon Q CLI
#
# This script first trusts all tools and then explicitly unsets trust
# for specific tools we want to restrict.

set -e  # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
DIVIDER="----------------------------------------"

echo -e "${DIVIDER}"
echo -e "${GREEN}Setting up Amazon Q trust permissions...${NC}"
echo -e "${DIVIDER}"

# Check if Amazon Q CLI is installed
if ! command -v q &> /dev/null; then
    echo -e "${RED}Error: Amazon Q CLI not found.${NC}"
    echo "Please install Amazon Q CLI first."
    exit 1
fi

# First, trust all tools
echo "Trusting all tools..."
q chat --no-interactive "/tools trustall"

# List of tools to explicitly untrust
# These are tools that might be considered higher risk
UNTRUSTED_TOOLS=(
    "execute_bash"
    "use_aws"
    "fs_write"
)

# Untrust specific tools
for tool in "${UNTRUSTED_TOOLS[@]}"; do
    echo "Untrusting tool: $tool"
    q chat --no-interactive "/tools untrust $tool"
done

echo -e "${GREEN}✅ Amazon Q trust permissions setup complete!${NC}"
echo "All tools are trusted except for the following:"
for tool in "${UNTRUSTED_TOOLS[@]}"; do
    echo "- $tool"
done
echo -e "${DIVIDER}"
