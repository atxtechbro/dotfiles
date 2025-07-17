# Claude Bedrock integration and MCP configuration
# Include this file in your .bashrc or .bash_aliases

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Conditional Bedrock integration - only on work machines
if [ "${WORK_MACHINE:-false}" = "true" ]; then
    # Claude with Bedrock (work machines only)
    # Uses ai_codegen profile and enables Bedrock integration
    alias claude-bedrock='AWS_PROFILE=ai_codegen CLAUDE_CODE_USE_BEDROCK=1 claude'
    
    # Make claude default to Bedrock on work machines - includes MCP config and knowledge directory
    alias claude='AWS_PROFILE=ai_codegen CLAUDE_CODE_USE_BEDROCK=1 claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
    
    echo "🏢 Work machine detected - Bedrock integration enabled"
else
    # Personal machines - Claude Pro Max with MCP config and knowledge directory
    alias claude='claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
    alias claude-bedrock='echo "❌ Bedrock not available on personal machines. Use claude instead."'
    
    echo "🏠 Personal machine detected - Using Claude Pro Max only"
fi

# Quick test command (works on both work and personal)
alias claude-test='claude -p "What is the capital of Texas?"'

