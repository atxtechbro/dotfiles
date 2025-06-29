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
    
    return 0
}

configure_claude_mcp() {
    echo "Configuring MCP servers for Claude Code..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    DOT_DEN="$(dirname "$SCRIPT_DIR")"
    
    # Run the MCP generator to create/update configurations
    if [[ -x "$DOT_DEN/mcp/generate-mcp-config.sh" ]]; then
        "$DOT_DEN/mcp/generate-mcp-config.sh"
    else
        echo "Warning: MCP generator not found, configurations may be outdated"
    fi
    
    # Claude Code supports multiple configuration scopes:
    # 1. Local scope: Project-specific user settings (via `claude mcp add`)
    #    - Private to current user and project
    #    - Not shared via version control
    #    - Highest priority
    #
    # 2. Project scope: .mcp.json in project root
    #    - Shared with team via version control
    #    - Good for project-specific servers
    #    - Medium priority
    #
    # 3. User scope: ~/.mcp.json (global across all projects)
    #    - Personal servers available everywhere
    #    - Good for general-purpose tools
    #    - Lowest priority (but what dotfiles uses by default)
    
    # The generator already handles all locations including:
    # - ~/.mcp.json (Claude Code user scope)
    # - $DOT_DEN/.mcp.json (project scope)
    # - ~/.aws/amazonq/mcp.json (Amazon Q)
    # - ~/.config/claude/claude_desktop_config.json (Claude Desktop)
    
    # List configured servers if possible
    MCP_CONFIG_DEST="$HOME/.mcp.json"
    if [ -f "$MCP_CONFIG_DEST" ] && command -v jq &> /dev/null; then
        echo "Configured MCP servers:"
        jq -r '.mcpServers | keys[]' "$MCP_CONFIG_DEST" 2>/dev/null | sed 's/^/  - /'
    fi
    
    echo -e "\n${BLUE}Claude Code MCP configuration scope guide:${NC}"
    echo -e "  • User scope (default): ~/.mcp.json - Your personal servers, available everywhere"
    echo -e "  • Project scope: .mcp.json - Team-shared servers for specific projects"
    echo -e "  • Local scope: claude mcp add - Private project overrides"
    echo -e "\n${YELLOW}To use different scopes:${NC}"
    echo -e "  • Force load from file: claude --mcp-config /path/to/mcp.json"
    echo -e "  • Add project server: claude mcp add --scope project <name> <command>"
    echo -e "  • Add local override: claude mcp add --scope local <name> <command>"
}

# Run setup if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_claude_code
fi