# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription
# DOT_DEN is set by .bash_exports (loaded before aliases in .bashrc)

# No default alias for `codex`:
# - Avoids masking the real binary and version-specific flags
# - Model selection via Codex defaults or ~/.codex/config.toml
# - Harness-agnostic, minimal surface area

# Convenience alias for 4o profile (configured in ~/.codex/config.toml)
alias codex-4o='codex --profile gpt4o'

# Test command - validates knowledge integration (positional prompt)
alias codex-test='codex "What is AI harness agnosticism and which two harnesses are currently configured?"'

# Update knowledge command - regenerates AGENTS.md from knowledge base
alias codex-update-knowledge='$DOT_DEN/utils/generate-codex-knowledge.sh'
