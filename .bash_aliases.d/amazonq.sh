# Amazon Q MCP integration and configuration
# Mirrors Claude setup pattern for provider agnosticism

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Function to ensure MCP config is imported
ensure_amazonq_mcp() {
    # Only import if config exists and q command is available
    if [[ -f "$GLOBAL_MCP_CONFIG" ]] && command -v q &> /dev/null; then
        # Import MCP config silently (suppress output unless error)
        q mcp import --file "$GLOBAL_MCP_CONFIG" global --force >/dev/null 2>&1 || true
    fi
}

# Amazon Q alias with automatic MCP import 🔥
alias q='ensure_amazonq_mcp && command q'

# Quick test command (mirrors claude-test)
alias q-test='q chat "What is the capital of Texas?"'

# MCP management aliases (mirrors Claude pattern)
alias q-mcp-list='q mcp list'
alias q-mcp-status='q mcp status'
