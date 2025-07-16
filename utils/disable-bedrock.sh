#!/usr/bin/env bash
# Disable Claude Code AWS Bedrock Integration
# Reverts to personal Claude Pro Max configuration

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}📌 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to unset Bedrock environment variables
unset_bedrock_environment() {
    print_step "Unsetting Claude Code Bedrock environment variables..."
    
    # Unset AWS Bedrock variables
    unset AWS_PROFILE
    unset CLAUDE_CODE_USE_BEDROCK
    unset AWS_REGION
    unset ANTHROPIC_MODEL
    
    # Set explicit disable variables (following Unix convention)
    export CLAUDE_CODE_USE_BEDROCK=0
    export CLAUDE_USE_BEDROCK=0
    export DISABLE_BEDROCK=1
    
    print_success "Bedrock environment variables unset"
    print_success "Claude Code will now use personal Anthropic API"
}

# Function to verify personal configuration
verify_personal_configuration() {
    print_step "Verifying personal Claude Pro Max configuration..."
    
    # Check that Bedrock is disabled
    if [[ "${CLAUDE_CODE_USE_BEDROCK:-0}" == "0" ]]; then
        print_success "CLAUDE_CODE_USE_BEDROCK=0 (Bedrock disabled)"
    else
        print_error "CLAUDE_CODE_USE_BEDROCK=${CLAUDE_CODE_USE_BEDROCK:-unset} (should be 0)"
        return 1
    fi
    
    # Check that AWS profile is unset
    if [[ -z "${AWS_PROFILE:-}" ]]; then
        print_success "AWS_PROFILE unset (will use personal authentication)"
    else
        print_warning "AWS_PROFILE still set to: $AWS_PROFILE"
        print_warning "This may interfere with personal Claude usage"
    fi
    
    print_success "Personal configuration verified!"
    return 0
}

# Main function
main() {
    echo "🏠 Disable Claude Code AWS Bedrock Integration"
    echo "=============================================="
    echo ""
    
    # Step 1: Unset environment variables
    unset_bedrock_environment
    
    echo ""
    
    # Step 2: Verify configuration
    if verify_personal_configuration; then
        echo ""
        print_success "Claude Code is now configured for personal Claude Pro Max!"
        echo ""
        echo "🧪 Test Commands:"
        echo "   claude-status                              # Check current configuration"
        echo "   claude -p \"What is the capital of Texas\"   # Test personal Claude usage"
        echo "   claude /status                             # Check API provider in interactive mode"
        echo ""
        echo "💡 To re-enable Bedrock for company usage:"
        echo "   source enable-bedrock.sh"
    else
        print_error "Configuration verification failed"
        exit 1
    fi
}

main "$@"
