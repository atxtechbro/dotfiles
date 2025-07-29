#!/bin/bash
# Claude Code configuration script
# Primary purpose: Configure Claude Code CLI with MCP servers and settings
# Secondary purpose: Install Claude Code if not present (trivial npm install)
#
# Configuration is the interesting problem - installation is a solved problem

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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# MAIN FUNCTION: Configuration is the star
# ============================================================================
configure_claude_code() {
    echo "Configuring Claude Code CLI..."
    
    # Installation is a prerequisite, not the main event
    if ! install_claude_if_needed; then
        return 1
    fi
    
    # ========================================================================
    # PRIMARY CONCERN: MCP Server Configuration
    # This is where the ongoing complexity and value lies
    # ========================================================================
    configure_mcp_servers
    
    # ========================================================================
    # IMPERATIVE SETTINGS: Runtime configuration that must always apply
    # ========================================================================
    configure_imperative_settings
    
    return 0
}

# ============================================================================
# HELPER: Trivial installation check
# Installation is a one-time solved problem, configuration is ongoing
# ============================================================================
install_claude_if_needed() {
    # Check prerequisites
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Node.js is not installed. Please install Node.js first.${NC}"
        return 1
    fi
    
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}npm is not installed. Please install npm first.${NC}"
        return 1
    fi
    
    # Check if Claude Code is already installed
    if command -v claude &> /dev/null; then
        # Get current version for informational purposes
        CURRENT_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        echo -e "${GREEN}✓ Claude Code is already installed (version: $CURRENT_VERSION)${NC}"
        return 0
    fi
    
    # Perform the trivial installation
    echo "Installing Claude Code CLI (one-time setup)..."
    if ! npm install -g @anthropic-ai/claude-code; then
        echo -e "${RED}Failed to install Claude Code CLI. Please try again or check your npm installation.${NC}"
        return 1
    fi
    
    VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    echo -e "${GREEN}✓ Claude Code successfully installed (version: $VERSION)${NC}"
    
    # Show initial setup instructions
    echo -e "\n${YELLOW}To complete Claude Code setup:${NC}"
    echo "1. Run: claude login"
    echo "2. Follow the authentication process"
    echo "3. MCP servers will be automatically configured next"
    
    return 0
}

# ============================================================================
# CONFIGURATION FUNCTION 1: MCP Server Setup
# This is the complex, evolving part that requires ongoing maintenance
# ============================================================================
configure_mcp_servers() {
    echo "Configuring MCP servers..."
    
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

# ============================================================================
# CONFIGURATION FUNCTION 2: Imperative Settings
# These settings must be applied at runtime and cannot be declarative
# ============================================================================
configure_imperative_settings() {
    if command -v claude &> /dev/null; then
        echo "Applying imperative settings..."
        
        # These settings cannot be managed declaratively and must be set imperatively
        claude config set -g autoUpdate true 2>/dev/null
        claude config set -g preferredNotifChannel terminal_bell 2>/dev/null
        claude config set -g verbose true 2>/dev/null
        
        echo -e "${GREEN}✓ Imperative settings applied${NC}"
    else
        echo -e "${YELLOW}Warning: Claude Code not found, skipping imperative settings${NC}"
    fi
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Run configuration if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_claude_code
fi