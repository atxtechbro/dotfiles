#!/bin/bash
# Setup all MCP servers with worktree support
# This script ensures all MCP servers are properly initialized
# whether running from main repo or a worktree

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory (works in worktrees)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR"
REPO_ROOT="$(dirname "$MCP_DIR")"

echo -e "${GREEN}Setting up all MCP servers...${NC}"
echo "Working directory: $REPO_ROOT"

# Detect if we're in a worktree
if git rev-parse --git-common-dir >/dev/null 2>&1; then
    GIT_COMMON_DIR=$(git rev-parse --git-common-dir)
    GIT_DIR=$(git rev-parse --git-dir)
    if [ "$GIT_COMMON_DIR" != "$GIT_DIR" ]; then
        echo -e "${YELLOW}Detected git worktree - ensuring local setup${NC}"
        IS_WORKTREE=true
    else
        IS_WORKTREE=false
    fi
else
    IS_WORKTREE=false
fi

# Run individual setup scripts
# NOTE: git/github MCP servers removed per issue #1215
# Direct CLI usage via Bash tool proved more reliable
setup_scripts=(
    # Add future MCP server setup scripts here
)

failed_setups=()

for script in "${setup_scripts[@]}"; do
    if [ -f "$MCP_DIR/$script" ]; then
        echo -e "\n${GREEN}Running $script...${NC}"
        if ! "$MCP_DIR/$script"; then
            echo -e "${RED}Failed to run $script${NC}"
            failed_setups+=("$script")
        fi
    else
        echo -e "${YELLOW}Warning: $script not found${NC}"
    fi
done

# Create servers directory if it doesn't exist
mkdir -p "$MCP_DIR/servers"

# Summary
echo -e "\n${GREEN}MCP Server Setup Summary:${NC}"
echo "- Working directory: $REPO_ROOT"
echo "- Is worktree: $IS_WORKTREE"
echo "- MCP directory: $MCP_DIR"
echo "- Servers directory: $MCP_DIR/servers"

if [ ${#failed_setups[@]} -gt 0 ]; then
    echo -e "\n${RED}Failed setups:${NC}"
    for failed in "${failed_setups[@]}"; do
        echo "  - $failed"
    done
    echo -e "\n${YELLOW}Some servers may not work properly. Please check the errors above.${NC}"
else
    echo -e "\n${GREEN}All MCP servers set up successfully!${NC}"
fi

# NOTE: Binary verification removed as git/github MCP servers
# have been deleted per issue #1215