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
setup_scripts=(
    "setup-github-mcp.sh"
    "setup-git-mcp.sh"
    "setup-filesystem-mcp.sh"
    "setup-brave-search-mcp.sh"
    "setup-gdrive-mcp.sh"
)

failed_setups=()

for script in "${setup_scripts[@]}"; do
    if [ -f "$MCP_DIR/$script" ]; then
        echo -e "\n${GREEN}Running $script...${NC}"
        
        # Special handling for Google Drive setup with timeout
        if [[ "$script" == "setup-gdrive-mcp.sh" ]]; then
            echo -e "${YELLOW}Note: Google Drive setup has a 30-second timeout to prevent hanging${NC}"
            if timeout 30s "$MCP_DIR/$script"; then
                echo -e "${GREEN}Google Drive setup completed${NC}"
            else
                exit_code=$?
                if [ $exit_code -eq 124 ]; then
                    echo -e "${YELLOW}Google Drive setup timed out after 30 seconds - continuing setup${NC}"
                    echo -e "${YELLOW}You can run 'mcp/setup-gdrive-mcp.sh' manually later if needed${NC}"
                else
                    echo -e "${RED}Google Drive setup failed with error code $exit_code${NC}"
                fi
                failed_setups+=("$script (timeout/error)")
            fi
        else
            # Normal execution for other scripts
            if ! "$MCP_DIR/$script"; then
                echo -e "${RED}Failed to run $script${NC}"
                failed_setups+=("$script")
            fi
        fi
    else
        echo -e "${YELLOW}Warning: $script not found${NC}"
    fi
done

# Generate MCP configuration for all clients
if [ -f "$MCP_DIR/generate-mcp-config.sh" ]; then
    echo -e "\n${GREEN}Generating MCP configurations...${NC}"
    "$MCP_DIR/generate-mcp-config.sh"
else
    echo -e "${YELLOW}Warning: generate-mcp-config.sh not found${NC}"
fi

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

# Verify critical binaries exist
echo -e "\n${GREEN}Verifying server binaries:${NC}"
binaries=(
    "servers/github"
    "servers/git-mcp-server/.venv/bin/python"
    "servers/filesystem-mcp-server/node_modules/.bin/filesystem-server"
)

for binary in "${binaries[@]}"; do
    if [ -e "$MCP_DIR/$binary" ]; then
        echo -e "  ✓ $binary"
    else
        echo -e "  ${RED}✗ $binary${NC}"
    fi
done