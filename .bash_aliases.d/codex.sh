# OpenAI Codex CLI integration and MCP configuration
# Requires ChatGPT Plus/Pro/Team subscription

# Define the dotfiles location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"

# No default alias for `codex`:
# - Avoids masking the real binary and version-specific flags
# - Model selection via Codex defaults or ~/.codex/config.toml
# - Provider-agnostic, minimal surface area

# Model override helper (per Codex docs: --config key=value)
codexm() {
  local model="$1"; shift || true
  codex --config "model=${model}" "$@"
}

# Convenience profile for 4o (configured in ~/.codex/config.toml)
alias codex-4o='codex --profile gpt4o'

# Model override helper using supported config override syntax
# Usage:
#   codexm <model> [prompt or flags...]
# Examples:
#   codexm chatgpt-4o-latest "Rewrite empathetically"
#   codexm gpt-5 "Summarize this diff"
codexm() {
  local model="$1"; shift || true
  codex --config "model=${model}" "$@"
}

# Convenience alias for 4o model (dialogue/empathetic tone)
alias codex-4o='codex --config model=chatgpt-4o-latest'

# Test command - validates knowledge integration (positional prompt)
alias codex-test='codex "What is AI provider agnosticism and which three providers have triple redundancy?"'

# Update knowledge command - regenerates AGENTS.md from knowledge base
alias codex-update-knowledge='$DOT_DEN/utils/generate-codex-knowledge.sh'
