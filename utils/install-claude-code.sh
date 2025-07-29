#!/bin/bash
# Claude Code installation and update script
# Installs or updates Claude Code CLI to the latest version

# Don't use set -e when this script might be sourced
# It would affect the parent shell and cause exits
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly, safe to use strict mode
    set -euo pipefail
fi

# Source shared utilities
# Get the directory of this script file specifically
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${UTILS_DIR}/version-utils.sh"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

setup_claude_code() {
    echo "Checking Claude Code CLI status..."
    
    # Check if Node.js is available
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Node.js is not installed. Please install Node.js first.${NC}"
        return 1
    fi
    
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}npm is not installed. Please install npm first.${NC}"
        return 1
    fi
    
    # Check if Claude Code is already installed
    if command -v claude &> /dev/null; then
        # Get current version
        CURRENT_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        echo "Claude Code is already installed (version: $CURRENT_VERSION)"
        
        # Get latest version from npm
        LATEST_VERSION=$(npm view @anthropic-ai/claude-code version 2>/dev/null || echo "unknown")
        
        if [ "$LATEST_VERSION" = "unknown" ]; then
            echo -e "${YELLOW}Could not determine latest version. Attempting to update anyway...${NC}"
            if ! npm update -g @anthropic-ai/claude-code; then
                echo -e "${RED}Failed to update Claude Code. Please try again or check your npm installation.${NC}"
                return 1
            fi
        elif [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
            echo -e "${GREEN}✓ Claude Code is already up to date (version: $CURRENT_VERSION)${NC}"
            return 0
        else
            # Use proper version comparison to prevent downgrades
            VERSION_COMPARISON=$(version_compare "$CURRENT_VERSION" "$LATEST_VERSION")
            
            if [ "$VERSION_COMPARISON" = "newer" ]; then
                echo -e "${GREEN}✓ Claude Code local version is newer (local: $CURRENT_VERSION, npm: $LATEST_VERSION)${NC}"
                return 0
            elif [ "$VERSION_COMPARISON" = "older" ]; then
                echo "Updating Claude Code from $CURRENT_VERSION to $LATEST_VERSION..."
                if ! npm update -g @anthropic-ai/claude-code; then
                    echo -e "${RED}Failed to update Claude Code. Please try again or check your npm installation.${NC}"
                    return 1
                fi
                
                NEW_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
                echo -e "${GREEN}✓ Claude Code successfully updated to version $NEW_VERSION${NC}"
            else
                echo -e "${GREEN}✓ Claude Code is already up to date (version: $CURRENT_VERSION)${NC}"
                return 0
            fi
        fi
    else
        # Install Claude Code
        echo "Installing Claude Code CLI..."
        if ! npm install -g @anthropic-ai/claude-code; then
            echo -e "${RED}Failed to install Claude Code CLI. Please try again or check your npm installation.${NC}"
            return 1
        else
            VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
            echo -e "${GREEN}✓ Claude Code successfully installed (version: $VERSION)${NC}"
            
            # Show initial setup instructions
            echo -e "\n${YELLOW}To complete Claude Code setup:${NC}"
            echo "1. Run: claude login"
            echo "2. Follow the authentication process"
            echo "3. MCP servers will be automatically configured by the dotfiles setup"
            echo -e "\n${BLUE}Optional: For PPV workflow optimization:${NC}"
            echo "cp .claude/settings/claude-code-ppv.json ~/.claude/settings.json"
        fi
    fi
    
    # Configure MCP servers for Claude Code
    configure_claude_mcp
    
    return 0
}

configure_claude_mcp() {
    echo "Checking MCP server configuration..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    DOT_DEN="$(dirname "$SCRIPT_DIR")"
    
    # Check if .mcp.json exists in the dotfiles repository
    if [[ -f "$DOT_DEN/.mcp.json" ]]; then
        echo -e "${GREEN}✓ MCP configuration found at $DOT_DEN/.mcp.json${NC}"
    else
        echo -e "${YELLOW}Warning: No .mcp.json found in dotfiles repository${NC}"
        echo "MCP servers will only be available when working in the dotfiles directory"
    fi
    
    # Dotfiles uses a simplified MCP configuration approach:
    # - Single .mcp.json file checked into source control
    # - All servers included (work-specific ones check environment at runtime)
    # - No template generation or machine-specific configs
    
    # List configured servers if .mcp.json exists
    if [ -f "$DOT_DEN/.mcp.json" ] && command -v jq &> /dev/null; then
        echo "Available MCP servers from dotfiles:"
        jq -r '.mcpServers | keys[]' "$DOT_DEN/.mcp.json" 2>/dev/null | sed 's/^/  - /'
    fi
    
    echo -e "\n${BLUE}MCP Configuration Notes:${NC}"
    echo -e "  • Global MCP config: $DOT_DEN/mcp/mcp.json"
    echo -e "  • ${GREEN}Global access enabled:${NC} 'claude' alias includes --mcp-config automatically"
    echo -e "  • MCP servers available from ANY directory after running setup.sh"
    echo -e "\n${YELLOW}Claude Code MCP commands:${NC}"
    echo -e "  • List servers: claude mcp list"
    echo -e "  • Add user-scoped server: claude mcp add <name> <command> -s user"
    echo -e "  • Check MCP info: claude-mcp-info"
    echo -e "  • Use strict global config: claude-global <command>"
}

# Run setup if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_claude_code
fi