#!/bin/bash
# Prevent accidental AWS Bedrock charges with Claude Code
# Variables documented at: https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock
# and https://docs.anthropic.com/en/docs/claude-code/settings

# Always unset Bedrock-related variables on shell startup
unset CLAUDE_CODE_USE_BEDROCK 2>/dev/null  # Official variable - when unset, Bedrock is disabled
unset AWS_BEARER_TOKEN_BEDROCK 2>/dev/null  # Official variable - removes Bedrock API key

# Alias to use safe wrapper
if [ -x "$HOME/.local/bin/claude-safe" ]; then
    alias claude='claude-safe'
fi

# Function to check Claude Code status without triggering Bedrock
claude-check-provider() {
    echo "Checking Claude Code provider safety..."
    
    # Check environment
    if env | grep -q "BEDROCK"; then
        echo "⚠️  WARNING: Bedrock environment variables detected!"
        env | grep "BEDROCK"
    else
        echo "✅ No Bedrock environment variables"
    fi
    
    # Check credentials
    if [ -f "$HOME/.claude/.credentials.json" ]; then
        if grep -q "claudeAiOauth" "$HOME/.claude/.credentials.json" 2>/dev/null; then
            echo "✅ Claude Pro authenticated"
        else
            echo "⚠️  Unknown authentication state"
        fi
    else
        echo "❌ No credentials file - need to login"
    fi
    
    # Check for AWS CLI configuration
    if [ -f "$HOME/.aws/credentials" ]; then
        echo "⚠️  AWS credentials exist - potential for Bedrock usage"
        echo "   Consider using: export AWS_PROFILE=non-bedrock-profile"
    fi
}

# Auto-check on first Claude Code usage in session
_claude_first_run_check() {
    if [ -z "$_CLAUDE_SAFETY_CHECKED" ]; then
        export _CLAUDE_SAFETY_CHECKED=1
        echo "🛡️  Claude Code Bedrock Protection Active"
    fi
}

# Hook into the claude command
claude-safe() {
    _claude_first_run_check
    command claude-safe "$@"
}