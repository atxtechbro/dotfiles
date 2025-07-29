DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# Claude alias with automatic Opus model on personal machines
if [[ "${WORK_MACHINE}" != "true" ]]; then
    alias claude='claude --model claude-opus-4-20250514 --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
else
    alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
fi

# Amazon Q uses MCP subcommands, not --mcp-config flag
# MCP servers are imported by setup-provider-agnostic-mcp.sh during setup
# To manually import: q mcp import --file "$DOT_DEN/mcp/mcp.json" global --force
alias q='q'