#!/bin/bash
# Claude Code MCP configuration alias
# This ensures Claude Code always uses the global MCP configuration from dotfiles

# Define the global MCP config location
# DOT_DEN is set by setup.sh, fallback to home dotfiles if not set
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Create claude alias that includes the MCP config
# This allows MCP servers to be available from any directory
alias claude='claude --mcp-config "$GLOBAL_MCP_CONFIG"'

# Optional: Add a variant that strictly uses only the global config
# (ignoring any local .mcp.json files)
alias claude-global='claude --mcp-config "$GLOBAL_MCP_CONFIG" --strict-mcp-config'

# Helpful function to check current MCP config
claude-mcp-info() {
    echo "Global MCP config: $GLOBAL_MCP_CONFIG"
    if [ -f "$GLOBAL_MCP_CONFIG" ]; then
        echo "✓ Config file exists"
        echo "Available MCP servers:"
        jq -r '.mcpServers | keys[]' "$GLOBAL_MCP_CONFIG" 2>/dev/null | sed 's/^/  - /' || echo "  (unable to parse config)"
    else
        echo "✗ Config file not found!"
        echo "  Run 'source ~/ppv/pillars/dotfiles/setup.sh' to set up MCP configuration"
    fi
}

# Optional: Completion for the aliased claude command
# This ensures tab completion still works with our alias
if command -v claude >/dev/null 2>&1; then
    complete -F _claude claude 2>/dev/null || true
    complete -F _claude claude-global 2>/dev/null || true
fi