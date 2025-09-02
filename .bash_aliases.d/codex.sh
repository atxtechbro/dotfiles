# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription

# Define the dotfiles location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# No default alias for `codex`:
# - Avoids masking the real binary and version-specific flags
# - Model selection via Codex defaults or ~/.codex/config.toml
# - Provider-agnostic, minimal surface area

# Test command - validates knowledge integration (positional prompt)
alias codex-test='codex "What is AI provider agnosticism and which three providers have triple redundancy?"'

# Update knowledge command - regenerates AGENTS.md from knowledge base
alias codex-update-knowledge='$DOT_DEN/utils/generate-codex-knowledge.sh'
