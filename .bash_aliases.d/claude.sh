# Claude Bedrock integration and MCP configuration

# Define the global MCP config location
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"

# Prevent accidental AWS Bedrock charges with Claude Code
# Documented in: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock
# and https://docs.anthropic.com/en/docs/claude-code/settings
unset CLAUDE_CODE_USE_BEDROCK  # Disables Bedrock when unset (official variable)
unset AWS_BEARER_TOKEN_BEDROCK  # Removes Bedrock API key if set (official variable)

# Locate the real Claude CLI installed via npm (avoids recursion when we wrap it)
__claude_locate_cli() {
  local prefix candidate path_candidate

  if prefix=$(npm prefix -g 2>/dev/null); then
    candidate="$prefix/bin/claude"
    if [[ -x "$candidate" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  fi

  path_candidate=$(type -P claude 2>/dev/null) || true
  if [[ -n "$path_candidate" && -x "$path_candidate" ]]; then
    printf '%s' "$path_candidate"
    return 0
  fi

  return 1
}

# One-time self-healing install per session (spilled coffee principle)
__claude_autoconfigure_once() {
  if [[ -n "${__CLAUDE_AUTOCONFIG_ATTEMPTED:-}" ]]; then
    return 1
  fi

  __CLAUDE_AUTOCONFIG_ATTEMPTED=1

  local configure_script="$DOT_DEN/utils/configure-claude-code.sh"
  if [[ -x "$configure_script" ]]; then
    "$configure_script" && hash -r
    return $?
  fi

  return 1
}

claude() {
  local dot_den="$DOT_DEN"
  local real_cli

  real_cli="$(__claude_locate_cli 2>/dev/null)" || true

  if [[ -z "$real_cli" ]]; then
    if __claude_autoconfigure_once; then
      real_cli="$(__claude_locate_cli 2>/dev/null)" || true
    fi
  fi

  if [[ -z "$real_cli" ]]; then
    echo "Claude CLI is not installed yet and automatic configuration failed." >&2
    echo "Run $dot_den/utils/configure-claude-code.sh manually to diagnose." >&2
    return 127
  fi

  "$real_cli" --verbose --mcp-config "$GLOBAL_MCP_CONFIG" --add-dir "$dot_den/knowledge" "$@"
}

# Quick test command - validates knowledge integration
alias claude-test='claude -p "What is AI provider agnosticism and which three providers have triple redundancy?"'
