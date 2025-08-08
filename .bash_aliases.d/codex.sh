# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription

# Define the dotfiles location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# Main alias with TOML config and GPT-5 model
alias codex='codex --config "$DOT_DEN/.codex/config.toml" --model "gpt-5-2025-08-07"'

# Test command
alias codex-test='codex -p "What is the capital of Texas?"'