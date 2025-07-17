# Provider-agnostic AI configuration
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Claude Code setup (with conditional Bedrock for work machines)
if command -v claude >/dev/null 2>&1; then
    if [ "${WORK_MACHINE:-false}" = "true" ]; then
        alias claude='AWS_PROFILE=ai_codegen CLAUDE_CODE_USE_BEDROCK=1 claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
    else
        alias claude='claude --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
    fi
fi

# Amazon Q setup
if command -v q >/dev/null 2>&1 && [ -f "$GLOBAL_MCP_CONFIG" ]; then
    alias q-ai='q --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'
fi

# Provider-agnostic alias - prefers Claude, falls back to Amazon Q
if command -v claude >/dev/null 2>&1; then
    alias ai='claude'
elif command -v q >/dev/null 2>&1 && [ -f "$GLOBAL_MCP_CONFIG" ]; then
    alias ai='q-ai'
fi