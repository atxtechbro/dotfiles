DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
alias claude-debug='DEBUG=1 claude -p --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
alias q='q --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'