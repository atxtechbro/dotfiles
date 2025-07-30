# Claude Bedrock integration and MCP configuration

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Prevent accidental AWS Bedrock charges with Claude Code
# Documented in: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock
# and https://docs.anthropic.com/en/docs/claude-code/settings
unset CLAUDE_CODE_USE_BEDROCK  # Disables Bedrock when unset (official variable)
unset AWS_BEARER_TOKEN_BEDROCK  # Removes Bedrock API key if set (official variable)

# Claude alias with MCP configuration
alias claude='claude --dangerously-skip-permissions --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'

# Quick test command (works on both work and personal)
alias claude-test='claude -p "What is the capital of Texas?"'

