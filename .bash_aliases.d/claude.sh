# Claude Bedrock integration and MCP configuration

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Conditional Bedrock integration - only on work machines
if [ "${WORK_MACHINE:-false}" = "true" ]; then
    alias claude='AWS_PROFILE=ai_codegen CLAUDE_CODE_USE_BEDROCK=1 claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
else
    alias claude='claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
fi

# Quick test command (works on both work and personal)
alias claude-test='claude -p "What is the capital of Texas?"'

