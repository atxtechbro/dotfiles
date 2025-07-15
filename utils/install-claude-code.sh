#!/bin/bash
# Claude Code installation and update script
# Installs or updates Claude Code CLI to the latest version

# Don't use set -e when this script might be sourced
# It would affect the parent shell and cause exits
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly, safe to use strict mode
    set -euo pipefail
fi

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
            echo "Updating Claude Code from $CURRENT_VERSION to $LATEST_VERSION..."
            if ! npm update -g @anthropic-ai/claude-code; then
                echo -e "${RED}Failed to update Claude Code. Please try again or check your npm installation.${NC}"
                return 1
            fi
            
            # Verify update
            NEW_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
            if [ "$NEW_VERSION" = "$LATEST_VERSION" ]; then
                echo -e "${GREEN}✓ Claude Code successfully updated to version $NEW_VERSION${NC}"
            else
                echo -e "${YELLOW}Update completed but version verification failed.${NC}"
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
        fi
    fi
    
    # Configure MCP servers for Claude Code
    configure_claude_mcp
    
    # Check for macOS authentication issues
    check_macos_auth_issues
    
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
    echo -e "  • Work-only servers (Atlassian, GitLab) require WORK_MACHINE=true"
    echo -e "  • ${GREEN}Global access enabled:${NC} 'claude' alias includes --mcp-config automatically"
    echo -e "  • MCP servers available from ANY directory after running setup.sh"
    echo -e "\n${YELLOW}Claude Code MCP commands:${NC}"
    echo -e "  • List servers: claude mcp list"
    echo -e "  • Add user-scoped server: claude mcp add <name> <command> -s user"
    echo -e "  • Check MCP info: claude-mcp-info"
    echo -e "  • Use strict global config: claude-global <command>"
}

check_macos_auth_issues() {
    # Only check on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        return 0
    fi
    
    # Check if Claude Code is installed and accessible
    if ! command -v claude &> /dev/null; then
        return 0
    fi
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    DOT_DEN="$(dirname "$SCRIPT_DIR")"
    
    # Try to detect if Opus model is accessible
    # Suppress all output and just check for the specific error
    local model_check=$(claude --model opus 2>&1 || true)
    
    if echo "$model_check" | grep -q "Invalid model.*Pro users"; then
        echo -e "\n${YELLOW}⚠️  Claude Code macOS Authentication Issue Detected${NC}"
        echo -e "${YELLOW}You appear to be affected by the Opus model access bug.${NC}"
        echo -e "${YELLOW}This prevents Claude Max users from accessing Opus on macOS.${NC}"
        echo -e "\nTo fix this issue, run:"
        echo -e "  ${GREEN}$DOT_DEN/utils/fix-claude-code-macos-auth.sh${NC}"
        echo -e "\nFor more info, see: https://github.com/anthropics/claude-code/issues/3566"
    fi
}

# Run setup if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_claude_code
fi