# Amazon Q MCP integration - mirrors Claude setup pattern

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Single q alias with automatic MCP import (mirrors claude alias)
alias q='q mcp import --file "$GLOBAL_MCP_CONFIG" global --force >/dev/null 2>&1; command q'
