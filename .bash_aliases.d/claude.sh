# Claude model switch aliases
# Include this file in your .bashrc or .bash_aliases

# Switch to Claude 3.5 Haiku model
alias claude-haiku="export ANTHROPIC_MODEL=claude-3-5-haiku-latest"

# Switch to Claude 3.7 Sonnet model
alias claude-sonnet="export ANTHROPIC_MODEL=claude-3-7-sonnet-latest"

# Switch to Claude 3 Opus model
alias claude-opus="export ANTHROPIC_MODEL=claude-3-opus-latest"

# Claude Code with AWS Bedrock
# This function checks AWS SSO status and runs Claude Code with Bedrock
claude-bedrock() {
    # Check if Bedrock exports are configured
    if [[ -z "$CLAUDE_CODE_USE_BEDROCK" ]] || [[ "$CLAUDE_CODE_USE_BEDROCK" != "1" ]]; then
        echo "Error: Bedrock environment not configured."
        echo "Please ensure ~/.bash_exports.bedrock.local exists and is sourced."
        echo "Run: source ~/.bashrc"
        return 1
    fi
    
    # Check if AWS profile is set
    if [[ -z "$AWS_PROFILE" ]]; then
        echo "Error: AWS_PROFILE not set."
        echo "Please set AWS_PROFILE in ~/.bash_exports.bedrock.local"
        return 1
    fi
    
    # Check AWS SSO login status
    if ! aws sts get-caller-identity --profile "$AWS_PROFILE" >/dev/null 2>&1; then
        echo "AWS SSO session expired or not logged in."
        echo "Running: aws sso login --profile $AWS_PROFILE"
        aws sso login --profile "$AWS_PROFILE"
        
        # Verify login succeeded
        if ! aws sts get-caller-identity --profile "$AWS_PROFILE" >/dev/null 2>&1; then
            echo "Error: AWS SSO login failed."
            return 1
        fi
    fi
    
    # Show current Bedrock configuration
    echo "Running Claude Code with AWS Bedrock:"
    echo "  Profile: $AWS_PROFILE"
    echo "  Region: $AWS_REGION"
    echo "  Model: ${ANTHROPIC_MODEL:-default}"
    echo ""
    
    # Run Claude Code with all arguments passed through
    claude "$@"
}

