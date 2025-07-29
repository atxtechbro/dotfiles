#!/bin/bash

# =========================================================
# MCP HEALTH CHECK UTILITY
# =========================================================
# PURPOSE: Check the health of all MCP servers
# Shows clear status for each server and suggests fixes
# =========================================================

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check a server's health
check_server_health() {
    local server_name="$1"
    local wrapper_path="$SCRIPT_DIR/${server_name}-mcp-wrapper.sh"
    local issues=()
    
    echo -n "Checking $server_name... "
    
    # Check if wrapper exists
    if [[ ! -f "$wrapper_path" ]]; then
        issues+=("Wrapper script not found at $wrapper_path")
    elif [[ ! -x "$wrapper_path" ]]; then
        issues+=("Wrapper script not executable")
    fi
    
    # Server-specific checks
    case "$server_name" in
        "git")
            local server_dir="$SCRIPT_DIR/servers/git-mcp-server"
            if [[ ! -d "$server_dir" ]]; then
                issues+=("Server directory not found: $server_dir")
            else
                if [[ ! -f "$server_dir/.venv/bin/python" ]]; then
                    issues+=("Python virtual environment not found. Run: setup-git-mcp.sh")
                fi
                if [[ ! -f "$server_dir/pyproject.toml" ]]; then
                    issues+=("Missing pyproject.toml - required for installation")
                fi
            fi
            ;;
            
        "github")
            local binary_path="$SCRIPT_DIR/servers/github"
            if [[ ! -x "$binary_path" ]]; then
                issues+=("Binary not found or not executable. Run: setup-github-mcp.sh")
            fi
            # Check GitHub CLI auth
            if ! gh auth status &>/dev/null; then
                issues+=("GitHub CLI not authenticated. Run: gh auth login")
            fi
            ;;
            
        "brave-search")
            # Check if npm/npx is available
            if ! command -v npx &>/dev/null; then
                issues+=("npx not found. Install Node.js: brew install node")
            fi
            # Check for API key
            if [[ -f ~/.bash_secrets ]]; then
                source ~/.bash_secrets
                if [[ -z "$BRAVE_API_KEY" ]]; then
                    issues+=("BRAVE_API_KEY not set in ~/.bash_secrets")
                fi
            else
                issues+=("~/.bash_secrets not found")
            fi
            ;;
            
        "playwright")
            # Check if npm/npx is available
            if ! command -v npx &>/dev/null; then
                issues+=("npx not found. Install Node.js: brew install node")
            fi
            ;;
            
        *)
            issues+=("Unknown server type: $server_name")
            ;;
    esac
    
    # Report status
    if [[ ${#issues[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓${NC} OK"
    else
        echo -e "${RED}✗${NC} FAIL"
        for issue in "${issues[@]}"; do
            echo -e "  ${YELLOW}→${NC} $issue"
        done
    fi
}

# Main script
echo "MCP Server Health Check"
echo "======================"
echo ""

# Check if mcp.json exists
if [[ ! -f "$SCRIPT_DIR/mcp.json" ]]; then
    echo -e "${RED}Error:${NC} mcp.json not found at $SCRIPT_DIR/mcp.json"
    exit 1
fi

# Extract server names from mcp.json
# Using grep and sed for simplicity (jq might not be installed)
server_names=$(grep -o '"[^"]*":' "$SCRIPT_DIR/mcp.json" | grep -v "mcpServers" | sed 's/[": ]//g' | sort)

if [[ -z "$server_names" ]]; then
    echo -e "${RED}Error:${NC} No servers found in mcp.json"
    exit 1
fi

# Check each server
has_failures=false
while IFS= read -r server; do
    check_server_health "$server"
    if [[ $? -ne 0 ]]; then
        has_failures=true
    fi
done <<< "$server_names"

echo ""
echo "Summary"
echo "-------"
if [[ "$has_failures" == "false" ]]; then
    echo -e "${GREEN}All MCP servers are healthy!${NC}"
else
    echo -e "${YELLOW}Some servers need attention. Run the suggested commands to fix issues.${NC}"
    echo ""
    echo "For more debugging information, run:"
    echo "  check-mcp-logs          # View recent errors"
    echo "  check-mcp-logs --follow # Monitor logs in real-time"
fi