# Claude Bedrock integration and MCP configuration

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Debug logging for work machine detection
echo "🔍 Claude Config Debug:"
echo "  WORK_MACHINE variable: '${WORK_MACHINE:-<unset>}'"
echo "  Evaluation result: '${WORK_MACHINE:-false}'"

# Conditional Bedrock integration - only on work machines
if [ "${WORK_MACHINE:-false}" = "true" ]; then
    echo "🏢 Work machine detected - Bedrock integration enabled"
    alias claude='AWS_PROFILE=ai_codegen CLAUDE_CODE_USE_BEDROCK=1 claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
else
    echo "🏠 Personal machine detected - Using Claude Pro Max only"
    alias claude='claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
fi

# Quick test command (works on both work and personal)
alias claude-test='claude -p "What is the capital of Texas?"'

