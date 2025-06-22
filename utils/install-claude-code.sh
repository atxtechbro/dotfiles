#!/bin/bash
# Claude Code installation and update script
# Installs or updates Claude Code CLI to the latest version

set -euo pipefail

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
    
    # Claude Code expects MCP configuration in these locations
    MCP_CONFIG_SOURCE="$DOT_DEN/mcp/mcp.json"
    
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
    
    # For dotfiles setup, we configure at USER SCOPE for global availability
    # This aligns with dotfiles philosophy: personal dev environment that works everywhere
    MCP_CONFIG_DEST="$HOME/.mcp.json"
    
    if [ -f "$MCP_CONFIG_SOURCE" ]; then
        # Copy MCP configuration to Claude Code's user-scope location
        cp "$MCP_CONFIG_SOURCE" "$MCP_CONFIG_DEST"
        
        # Apply environment-specific filtering if available
        if [ -f "$DOT_DEN/utils/mcp-environment.sh" ]; then
            # Source the MCP environment utility (suppress output)
            source "$DOT_DEN/utils/mcp-environment.sh" >/dev/null 2>&1
            
            # Detect current environment
            CURRENT_ENV=$(detect_environment)
            
            # Apply environment-specific configuration
            filter_mcp_config "$MCP_CONFIG_DEST" "$CURRENT_ENV"
        fi
        
        echo -e "${GREEN}✓ MCP servers configured for Claude Code at user scope (~/.mcp.json)${NC}"
        
        # List configured servers
        if command -v jq &> /dev/null; then
            echo "Configured MCP servers:"
            jq -r '.mcpServers | keys[]' "$MCP_CONFIG_DEST" 2>/dev/null | sed 's/^/  - /'
        fi
        
        # Also create a project-specific .mcp.json in dotfiles for when working in this repo
        PROJECT_MCP="$DOT_DEN/.mcp.json"
        if [ ! -f "$PROJECT_MCP" ]; then
            cp "$MCP_CONFIG_SOURCE" "$PROJECT_MCP"
            echo -e "${GREEN}✓ Created project-scope MCP configuration for dotfiles repo${NC}"
        fi
        
        echo -e "\n${BLUE}Claude Code MCP configuration scope guide:${NC}"
        echo -e "  • User scope (default): ~/.mcp.json - Your personal servers, available everywhere"
        echo -e "  • Project scope: .mcp.json - Team-shared servers for specific projects"
        echo -e "  • Local scope: claude mcp add - Private project overrides"
        echo -e "\n${YELLOW}To use different scopes:${NC}"
        echo -e "  • Force load from file: claude --mcp-config /path/to/mcp.json"
        echo -e "  • Add project server: claude mcp add --scope project <name> <command>"
        echo -e "  • Add local override: claude mcp add --scope local <name> <command>"
    else
        echo -e "${YELLOW}Warning: MCP configuration not found at $MCP_CONFIG_SOURCE${NC}"
        echo "MCP servers will need to be configured manually."
    fi
}

# Run setup if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_claude_code
fi