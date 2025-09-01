# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription

# Define the dotfiles location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# Main alias - keep existing default (gpt-5)
alias codex='codex -m gpt-5'

# Optional: 4o variant for dialogue/empathetic tone (useful for .md edits)
alias codex-4o='codex -m chatgpt-4o-latest'

# Test command - validates knowledge integration
alias codex-test='codex -p "What is AI provider agnosticism and which three providers have triple redundancy?"'

# Update knowledge command - regenerates AGENTS.md from knowledge base
alias codex-update-knowledge='$DOT_DEN/utils/generate-codex-knowledge.sh'
