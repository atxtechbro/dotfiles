#!/usr/bin/env bash
# Claude Status - Lightweight status checker for Claude Code configuration
# Shows current authentication method: Bedrock or Personal Claude Pro Max

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    local status="$1"
    local color="$2"
    echo -e "${color}● ${status}${NC}"
}

# Check Claude Code Bedrock environment variables
check_bedrock_config() {
    if [[ "${CLAUDE_CODE_USE_BEDROCK:-0}" == "1" ]]; then
        echo "🔧 Bedrock Configuration:"
        print_status "CLAUDE_CODE_USE_BEDROCK=1" "$GREEN"
        
        # Check AWS Profile
        if [[ -n "${AWS_PROFILE:-}" ]]; then
            print_status "AWS_PROFILE=${AWS_PROFILE}" "$GREEN"
        else
            print_status "AWS_PROFILE not set" "$RED"
        fi
        
        # Check AWS Region
        if [[ -n "${AWS_REGION:-}" ]]; then
            print_status "AWS_REGION=${AWS_REGION}" "$GREEN"
        else
            print_status "AWS_REGION not set" "$RED"
        fi
        
        # Check Anthropic Model
        if [[ -n "${ANTHROPIC_MODEL:-}" ]]; then
            print_status "ANTHROPIC_MODEL=${ANTHROPIC_MODEL}" "$GREEN"
        else
            print_status "ANTHROPIC_MODEL not set" "$RED"
        fi
        
        # Check AWS Authentication
        echo ""
        echo "🔐 AWS Authentication:"
        if aws_identity=$(aws sts get-caller-identity 2>/dev/null); then
            local account=$(echo "$aws_identity" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
            local arn=$(echo "$aws_identity" | grep -o '"Arn": "[^"]*"' | cut -d'"' -f4)
            
            if [[ "$account" == "193501891505" ]]; then
                print_status "AWS Account: $account ✓" "$GREEN"
            else
                print_status "AWS Account: $account (Expected: 193501891505)" "$RED"
            fi
            print_status "AWS ARN: $arn" "$BLUE"
        else
            print_status "AWS Authentication: Failed" "$RED"
        fi
        
        return 0
    else
        echo "🏠 Personal Claude Pro Max Configuration:"
        print_status "CLAUDE_CODE_USE_BEDROCK=${CLAUDE_CODE_USE_BEDROCK:-0}" "$GREEN"
        print_status "Using direct Anthropic API" "$GREEN"
        return 1
    fi
}

# Main status check
main() {
    echo "Claude Code Status"
    echo "=================="
    
    # Check if Claude Code is installed
    if ! command -v claude >/dev/null 2>&1; then
        print_status "Claude Code: Not installed" "$RED"
        exit 1
    else
        local version=$(claude --version 2>/dev/null || echo "unknown")
        print_status "Claude Code: $version" "$GREEN"
    fi
    
    echo ""
    
    # Check configuration
    if check_bedrock_config; then
        echo ""
        echo "🎯 Expected Test Result:"
        echo "   claude -p \"What is the capital of Texas\" should use AWS Bedrock"
        echo "   /status should show 'API Provider: AWS Bedrock'"
    else
        echo ""
        echo "🎯 Expected Test Result:"
        echo "   claude -p \"What is the capital of Texas\" should use Anthropic API"
        echo "   /status should show 'API Provider: Anthropic'"
    fi
}

main "$@"
