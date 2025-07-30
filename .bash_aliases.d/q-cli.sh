# Amazon Q CLI - Development aliases
# Include this file in your .bashrc or .bash_aliases

# Build Amazon Q CLI from source
alias q-build="cd $HOME/ppv/pillars/q-cli && cargo build --release"

# Run the compiled release version
alias q-run="$HOME/ppv/pillars/q-cli/target/release/q"

# Quick development testing (build and run in one step)
alias q-dev="cd $HOME/ppv/pillars/q-cli && cargo run --bin q_cli -- chat"

# Define the global MCP config location (same as claude.sh)
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Amazon Q alias with auto-trust and MCP configuration (mirrors Claude setup)
alias q='q chat /tools trustall --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$DOT_DEN/knowledge"'

