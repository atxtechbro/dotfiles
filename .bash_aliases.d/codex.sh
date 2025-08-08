# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription

# Define the dotfiles location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# Test command - validates knowledge integration
alias codex-test='codex -p "What is AI provider agnosticism and which three providers have triple redundancy?"'

# Update knowledge command - regenerates AGENTS.md from knowledge base
alias codex-update-knowledge='$DOT_DEN/utils/generate-codex-knowledge.sh'