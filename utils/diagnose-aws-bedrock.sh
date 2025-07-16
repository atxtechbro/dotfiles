#!/usr/bin/env bash
# Diagnose AWS Bedrock Configuration Issues
# Helps troubleshoot authentication and permissions

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_check() {
    echo -e "${GREEN}✓${NC} $1"
}

print_issue() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check AWS CLI installation
check_aws_cli() {
    print_section "AWS CLI Installation"
    
    if command -v aws >/dev/null 2>&1; then
        local version=$(aws --version 2>&1 | head -1)
        print_check "AWS CLI installed: $version"
    else
        print_issue "AWS CLI not found"
        return 1
    fi
}

# Check AWS configuration
check_aws_config() {
    print_section "AWS Configuration"
    
    local config_file="$HOME/.aws-isolated/config"
    if [[ -f "$config_file" ]]; then
        print_check "AWS config file found: $config_file"
        echo ""
        echo "Configuration contents:"
        cat "$config_file"
    else
        print_issue "AWS config file not found: $config_file"
        
        # Check standard location
        if [[ -f "$HOME/.aws/config" ]]; then
            print_warning "Found config at standard location: $HOME/.aws/config"
            echo ""
            echo "Configuration contents:"
            cat "$HOME/.aws/config"
        fi
    fi
}

# Check current AWS authentication
check_current_auth() {
    print_section "Current AWS Authentication"
    
    if aws_identity=$(aws sts get-caller-identity 2>/dev/null); then
        local account=$(echo "$aws_identity" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
        local arn=$(echo "$aws_identity" | grep -o '"Arn": "[^"]*"' | cut -d'"' -f4)
        
        print_check "Current AWS Account: $account"
        print_check "Current AWS ARN: $arn"
        
        if [[ "$account" == "193501891505" ]]; then
            print_check "✓ Authenticated to target account!"
        else
            print_issue "✗ Wrong account - need 193501891505, got $account"
        fi
    else
        print_issue "No AWS authentication found"
    fi
}

# Check ai_codegen profile
check_ai_codegen_profile() {
    print_section "AI CodeGen Profile Test"
    
    echo "Testing ai_codegen profile authentication..."
    if aws sts get-caller-identity --profile ai_codegen 2>/dev/null; then
        print_check "ai_codegen profile works!"
    else
        print_issue "ai_codegen profile authentication failed"
        echo ""
        echo "Error details:"
        aws sts get-caller-identity --profile ai_codegen 2>&1 || true
    fi
}

# Check SSO status
check_sso_status() {
    print_section "AWS SSO Status"
    
    echo "Checking SSO login status..."
    if aws sso list-accounts --profile ai_codegen 2>/dev/null >/dev/null; then
        print_check "SSO session is active"
        
        echo ""
        echo "Available accounts:"
        aws sso list-accounts --profile ai_codegen 2>/dev/null || print_warning "Could not list accounts"
    else
        print_issue "SSO session expired or not authenticated"
        echo ""
        echo "To fix, run: aws sso login --profile ai_codegen"
    fi
}

# Check Bedrock permissions
check_bedrock_permissions() {
    print_section "Bedrock Permissions Test"
    
    echo "Testing Bedrock model access..."
    local model_arn="arn:aws:bedrock:us-east-1:193501891505:inference-profile/us.anthropic.claude-sonnet-4-20250514-v1:0"
    
    # Try to list foundation models as a basic permission test
    if aws bedrock list-foundation-models --region us-east-1 --profile ai_codegen 2>/dev/null >/dev/null; then
        print_check "Basic Bedrock access works"
        
        # Try to invoke the specific model (this will fail but shows the exact error)
        echo ""
        echo "Testing specific model access:"
        echo "Model ARN: $model_arn"
        
        # Create a minimal test payload
        local test_payload='{"messages":[{"role":"user","content":"test"}],"max_tokens":10}'
        
        if aws bedrock-runtime invoke-model \
            --model-id "$model_arn" \
            --body "$test_payload" \
            --region us-east-1 \
            --profile ai_codegen \
            /tmp/bedrock-test-output.json 2>/dev/null; then
            print_check "Model invocation successful!"
            echo "Response:"
            cat /tmp/bedrock-test-output.json
            rm -f /tmp/bedrock-test-output.json
        else
            print_issue "Model invocation failed"
            echo ""
            echo "Error details:"
            aws bedrock-runtime invoke-model \
                --model-id "$model_arn" \
                --body "$test_payload" \
                --region us-east-1 \
                --profile ai_codegen \
                /tmp/bedrock-test-output.json 2>&1 || true
        fi
    else
        print_issue "No Bedrock access with ai_codegen profile"
        echo ""
        echo "Error details:"
        aws bedrock list-foundation-models --region us-east-1 --profile ai_codegen 2>&1 || true
    fi
}

# Main diagnostic function
main() {
    echo "🔍 AWS Bedrock Configuration Diagnostics"
    echo "========================================"
    
    check_aws_cli
    check_aws_config
    check_current_auth
    check_ai_codegen_profile
    check_sso_status
    check_bedrock_permissions
    
    print_section "Summary & Next Steps"
    echo ""
    echo "If you see authentication errors above:"
    echo "1. Contact Omar to verify your permissions in account 193501891505"
    echo "2. Confirm the CodeGeneration role exists and you have access"
    echo "3. Try: aws sso login --profile ai_codegen"
    echo ""
    echo "If authentication works but Bedrock fails:"
    echo "1. Verify the model ARN is correct"
    echo "2. Check if the inference profile exists in the target account"
    echo "3. Confirm Bedrock permissions are attached to the CodeGeneration role"
}

main "$@"
