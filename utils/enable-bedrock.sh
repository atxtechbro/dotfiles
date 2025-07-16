#!/usr/bin/env bash
# Enable Claude Code AWS Bedrock Integration
# Configures environment for company AWS Bedrock usage

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

# Function to authenticate to correct AWS account
authenticate_aws() {
    print_step "Authenticating to AWS account 193501891505..."
    
    # Check if already authenticated to correct account
    if aws_identity=$(aws sts get-caller-identity 2>/dev/null); then
        local current_account=$(echo "$aws_identity" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
        
        if [[ "$current_account" == "193501891505" ]]; then
            print_success "Already authenticated to correct AWS account: $current_account"
            return 0
        else
            print_warning "Currently authenticated to account: $current_account"
            print_step "Need to authenticate to account: 193501891505"
        fi
    fi
    
    # Perform SSO login
    print_step "Running AWS SSO login for ai_codegen profile..."
    if aws sso login --profile ai_codegen; then
        print_success "AWS SSO login completed"
        
        # Verify authentication
        if aws_identity=$(aws sts get-caller-identity --profile ai_codegen 2>/dev/null); then
            local new_account=$(echo "$aws_identity" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
            if [[ "$new_account" == "193501891505" ]]; then
                print_success "Verified authentication to account: $new_account"
                return 0
            else
                print_error "Authentication failed - got account: $new_account, expected: 193501891505"
                return 1
            fi
        else
            print_error "Failed to verify AWS authentication"
            return 1
        fi
    else
        print_error "AWS SSO login failed"
        return 1
    fi
}

# Function to set environment variables
set_bedrock_environment() {
    print_step "Setting Claude Code Bedrock environment variables..."
    
    # Set the required environment variables
    export AWS_PROFILE=ai_codegen
    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_REGION=us-east-1
    export ANTHROPIC_MODEL='arn:aws:bedrock:us-east-1:193501891505:inference-profile/us.anthropic.claude-sonnet-4-20250514-v1:0'
    
    print_success "Environment variables set:"
    echo "  AWS_PROFILE=$AWS_PROFILE"
    echo "  CLAUDE_CODE_USE_BEDROCK=$CLAUDE_CODE_USE_BEDROCK"
    echo "  AWS_REGION=$AWS_REGION"
    echo "  ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
}

# Function to verify configuration
verify_configuration() {
    print_step "Verifying Claude Code Bedrock configuration..."
    
    # Check environment variables
    local missing_vars=()
    [[ -z "${AWS_PROFILE:-}" ]] && missing_vars+=("AWS_PROFILE")
    [[ "${CLAUDE_CODE_USE_BEDROCK:-0}" != "1" ]] && missing_vars+=("CLAUDE_CODE_USE_BEDROCK")
    [[ -z "${AWS_REGION:-}" ]] && missing_vars+=("AWS_REGION")
    [[ -z "${ANTHROPIC_MODEL:-}" ]] && missing_vars+=("ANTHROPIC_MODEL")
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_error "Missing environment variables: ${missing_vars[*]}"
        return 1
    fi
    
    # Check AWS authentication
    if aws_identity=$(aws sts get-caller-identity 2>/dev/null); then
        local account=$(echo "$aws_identity" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
        if [[ "$account" == "193501891505" ]]; then
            print_success "AWS authentication verified for account: $account"
        else
            print_error "AWS authentication error - current account: $account, expected: 193501891505"
            return 1
        fi
    else
        print_error "AWS authentication failed"
        return 1
    fi
    
    print_success "Configuration verified successfully!"
    return 0
}

# Main function
main() {
    echo "🚀 Enable Claude Code AWS Bedrock Integration"
    echo "============================================="
    echo ""
    
    # Step 1: Authenticate to AWS
    if ! authenticate_aws; then
        print_error "Failed to authenticate to AWS"
        exit 1
    fi
    
    echo ""
    
    # Step 2: Set environment variables
    set_bedrock_environment
    
    echo ""
    
    # Step 3: Verify configuration
    if verify_configuration; then
        echo ""
        print_success "Claude Code is now configured for AWS Bedrock!"
        echo ""
        echo "🧪 Test Commands:"
        echo "   claude-status                              # Check current configuration"
        echo "   claude -p \"What is the capital of Texas\"   # Test Bedrock integration"
        echo "   claude /status                             # Check API provider in interactive mode"
        echo ""
        echo "💡 To disable Bedrock and return to personal Claude Pro Max:"
        echo "   source disable-bedrock.sh"
    else
        print_error "Configuration verification failed"
        exit 1
    fi
}

main "$@"
