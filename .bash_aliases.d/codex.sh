# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription

# Define the dotfiles location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# No default alias for `codex`:
# - Avoids masking the real binary and version-specific flags
# - Model selection via Codex defaults or ~/.codex/config.toml
# - Harness-agnostic, minimal surface area

# Convenience alias for 4o profile (configured in ~/.codex/config.toml)
alias codex-4o='codex --profile gpt4o'

# Test command - validates knowledge integration (positional prompt)
alias codex-test='codex "What is AI harness agnosticism and which development harnesses support dual redundancy?"'

# Update knowledge command - regenerates AGENTS.md from knowledge base
alias codex-update-knowledge='$DOT_DEN/utils/generate-codex-knowledge.sh'
