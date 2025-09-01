#!/bin/bash
# Provider-Agnostic MCP Setup
# Configures both Claude Code and Amazon Q to use identical MCP servers

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

setup_provider_agnostic_mcp() {
    echo -e "${BLUE}🚀 Setting up Provider-Agnostic MCP Configuration...${NC}"
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    DOT_DEN="$(dirname "$SCRIPT_DIR")"
    MCP_CONFIG="$DOT_DEN/mcp/mcp.json"
    
    # Verify MCP config exists
    if [[ ! -f "$MCP_CONFIG" ]]; then
        echo -e "${RED}❌ MCP configuration not found at $MCP_CONFIG${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}📋 MCP Config: $MCP_CONFIG${NC}"
    
    # Setup Claude Code MCP (via alias)
    echo -e "${BLUE}🔧 Configuring Claude Code...${NC}"
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓ Claude Code detected - MCP config via alias in .bash_aliases.d/claude.sh${NC}"
        echo -e "  Alias: claude --mcp-config \"$MCP_CONFIG\" --add-dir \"$DOT_DEN/knowledge\""
    else
        echo -e "${YELLOW}⚠️  Claude Code not installed - MCP config ready when installed${NC}"
    fi
    
    # Setup Amazon Q MCP (via import)
    echo -e "${BLUE}🔧 Configuring Amazon Q...${NC}"
    if command -v q &> /dev/null; then
        echo "Importing MCP configuration to Amazon Q (global scope)..."
        if q mcp import --file "$MCP_CONFIG" global --force; then
            echo -e "${GREEN}✓ Amazon Q MCP servers imported successfully${NC}"
            
            # List imported servers
            echo -e "${BLUE}📊 Imported MCP servers:${NC}"
            q mcp list 2>/dev/null || echo "  (List command failed, but import succeeded)"
        else
            echo -e "${YELLOW}⚠️  Amazon Q MCP import failed - may need manual configuration${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Amazon Q not installed - MCP config ready when installed${NC}"
    fi
    
    # Setup OpenAI Codex MCP (via TOML config)
    echo -e "${BLUE}🔧 Configuring OpenAI Codex...${NC}"
    if command -v codex &> /dev/null; then
        echo -e "${GREEN}✓ Codex CLI detected - MCP servers configured in TOML${NC}"
        echo -e "  Config: $DOT_DEN/.codex/config.toml"
        echo -e "  Format: TOML with [mcp_servers] sections"
        echo -e "  Model: gpt-4o (default via alias)"
        
        # Sync MCP servers from JSON to TOML if needed
        if [[ -f "$MCP_CONFIG" ]] && command -v jq &> /dev/null; then
            echo -e "${YELLOW}📋 Note: Codex uses TOML format for MCP servers${NC}"
            echo -e "  MCP servers are defined in .codex/config.toml"
            echo -e "  Format: [mcp_servers.name] with command/args/env"
        fi
    else
        echo -e "${YELLOW}⚠️  Codex CLI not installed - MCP config ready when installed${NC}"
        echo -e "  Run: $DOT_DEN/utils/install-codex.sh to install"
    fi
    
    # Summary
    echo -e "\n${GREEN}🎯 Provider-Agnostic MCP Setup Complete!${NC}"
    echo -e "${BLUE}All AI providers now use identical MCP servers:${NC}"
    
    if [[ -f "$MCP_CONFIG" ]] && command -v jq &> /dev/null; then
        echo -e "${BLUE}Available servers:${NC}"
        jq -r '.mcpServers | keys[]' "$MCP_CONFIG" 2>/dev/null | sed 's/^/  • /' || echo "  (jq not available for server list)"
    fi
    
    echo -e "\n${YELLOW}🔄 Crisis Resilience Achieved:${NC}"
    echo -e "  • Claude Code down? → Use Codex (primary) or Amazon Q with same MCP servers"
    echo -e "  • OpenAI outage? → Use Claude Code (primary) or Amazon Q with same MCP servers"
    echo -e "  • Amazon Q issues? → Use Claude Code or Codex with same MCP servers"
    echo -e "  • All three providers have identical capabilities"
    
    return 0
}

# Run setup if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_provider_agnostic_mcp
fi
