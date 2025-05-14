#!/bin/bash
# Amazon Q Trust Setup Script
# Sets up trusted tools for Amazon Q CLI
#
# This script configures Amazon Q trust permissions in a single command
# to avoid multiple Amazon Q initialization cycles.

set -e  # Exit on error

# Define colors properly with double quotes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color
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

# Get the actual path to the q binary to avoid recursion
Q_BIN=$(which q)

# List of tools to explicitly untrust
UNTRUSTED_TOOLS="execute_bash use_aws fs_write"

# Create a temporary script file with all commands
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << EOF
/tools trustall
/tools untrust ${UNTRUSTED_TOOLS}
/quit
EOF

# Run all commands in a single Amazon Q session
echo "Configuring Amazon Q trust permissions..."
"$Q_BIN" chat --no-interactive < "$TEMP_SCRIPT"

# Clean up
rm "$TEMP_SCRIPT"

echo -e "${GREEN}✅ Amazon Q trust permissions setup complete!${NC}"
echo "All tools are trusted except for the following:"
for tool in $UNTRUSTED_TOOLS; do
    echo "- $tool"
done
echo -e "${DIVIDER}"
