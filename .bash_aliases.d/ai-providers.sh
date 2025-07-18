DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# Claude alias with automatic Opus model on personal machines
if [[ "${WORK_MACHINE}" != "true" ]]; then
    alias claude='claude --model claude-opus-4-20250514 --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
else
    alias claude='claude --mcp-config "$DOT_DEN/mcp/mcp.json" --add-dir "$DOT_DEN/knowledge"'
fi

DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# Common parameters for claude and q aliases
COMMON_PARAMS="--mcp-config \"$DOT_DEN/mcp/mcp.json\" --add-dir \"$DOT_DEN/knowledge\""

# Claude alias with automatic Opus model on personal machines
if [[ "${WORK_MACHINE}" != "true" ]]; then
    alias claude="claude --model claude-opus-4-20250514 $COMMON_PARAMS"
else
    alias claude="claude $COMMON_PARAMS"
fi

alias q="q $COMMON_PARAMS"