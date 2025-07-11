#!/bin/bash
# Setup script for Claude Code AWS Bedrock integration
set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Claude Code AWS Bedrock integration...${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check AWS SSO login status
check_aws_sso_status() {
    local profile="${1:-$AWS_PROFILE}"
    if [[ -z "$profile" ]]; then
        return 1
    fi
    
    # Try to get caller identity
    if aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to setup Bedrock exports
setup_bedrock_exports() {
    local DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
    local template_file="$DOT_DEN/.bash_exports.bedrock.template"
    local local_file="$HOME/.bash_exports.bedrock.local"
    
    if [[ ! -f "$template_file" ]]; then
        echo -e "${RED}Error: Template file not found at $template_file${NC}"
        return 1
    fi
    
    if [[ -f "$local_file" ]]; then
        echo -e "${GREEN}Bedrock exports file already exists at $local_file${NC}"
        echo -e "${GREEN}Keeping existing configuration${NC}"
        return 0
    fi
    
    # Create new file from template
    cp "$template_file" "$local_file"
    echo -e "${GREEN}Created Bedrock exports file at $local_file${NC}"
    echo -e "${YELLOW}Please edit this file to add your specific AWS account details${NC}"
}

# Function to setup AWS config
setup_aws_config() {
    local DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
    local template_file="$DOT_DEN/aws/config.template"
    local aws_config_dir="$HOME/.aws"
    local aws_config_file="$aws_config_dir/config"
    
    # Create .aws directory if it doesn't exist
    mkdir -p "$aws_config_dir"
    
    if [[ ! -f "$template_file" ]]; then
        echo -e "${RED}Error: AWS config template not found at $template_file${NC}"
        return 1
    fi
    
    if [[ -f "$aws_config_file" ]]; then
        echo -e "${GREEN}AWS config already exists at $aws_config_file${NC}"
        
        # Check if bedrock_profile already exists
        if grep -q "profile bedrock_profile" "$aws_config_file" 2>/dev/null; then
            echo -e "${GREEN}Bedrock profile already configured${NC}"
            return 0
        else
            # Append the template
            echo "" >> "$aws_config_file"
            echo "# Added by dotfiles setup-bedrock-claude.sh on $(date)" >> "$aws_config_file"
            cat "$template_file" >> "$aws_config_file"
            echo -e "${GREEN}Appended Bedrock profile template to AWS config${NC}"
            echo -e "${YELLOW}Please edit $aws_config_file to customize the profile${NC}"
        fi
    else
        # Create new config from template
        cp "$template_file" "$aws_config_file"
        echo -e "${GREEN}Created AWS config at $aws_config_file${NC}"
        echo -e "${YELLOW}Please edit this file to add your specific AWS SSO details${NC}"
    fi
}

# Main setup function
main() {
    # Check for AWS CLI
    if ! command_exists aws; then
        echo -e "${RED}AWS CLI is not installed${NC}"
        echo "Please install AWS CLI first: https://aws.amazon.com/cli/"
        return 1
    fi
    
    # Check for Claude Code
    if ! command_exists claude; then
        echo -e "${YELLOW}Claude Code is not installed${NC}"
        echo "Installing Claude Code is recommended before using Bedrock integration"
    fi
    
    # Setup AWS config
    echo -e "${BLUE}Step 1: Setting up AWS configuration${NC}"
    setup_aws_config
    
    # Setup Bedrock exports
    echo -e "${BLUE}Step 2: Setting up Bedrock environment variables${NC}"
    setup_bedrock_exports
    
    # Check if .bashrc sources the Bedrock exports
    if ! grep -q ".bash_exports.bedrock.local" "$HOME/.bashrc" 2>/dev/null; then
        echo -e "${BLUE}Step 3: Adding Bedrock exports to .bashrc${NC}"
        echo "" >> "$HOME/.bashrc"
        echo "# Source Bedrock exports if available" >> "$HOME/.bashrc"
        echo "[[ -f ~/.bash_exports.bedrock.local ]] && source ~/.bash_exports.bedrock.local" >> "$HOME/.bashrc"
        echo -e "${GREEN}Added Bedrock exports to .bashrc${NC}"
    else
        echo -e "${GREEN}Bedrock exports already configured in .bashrc${NC}"
    fi
    
    echo
    echo
    echo -e "${GREEN}Bedrock setup complete!${NC}"
    echo
    echo -e "${BLUE}Important:${NC} This Bedrock configuration will override the default Claude Code setup."
    echo "- Default: ~/.bash_exports.claude.local (standard Anthropic API)"
    echo "- Bedrock: ~/.bash_exports.bedrock.local (AWS Bedrock - loaded after defaults)"
    echo
    echo "Next steps:"
    echo "1. Edit ~/.bash_exports.bedrock.local with your AWS account details"
    echo "2. Edit ~/.aws/config with your SSO configuration"
    echo "3. Run: aws sso login --profile bedrock_profile"
    echo "4. Run: source ~/.bashrc"
    echo "5. Run: claude-bedrock (or just 'claude' with Bedrock env vars set)"
    echo
    echo "To temporarily use default Claude Code, run: source ~/.bash_exports.claude.local"
    echo "For more information, see: docs/claude-bedrock-setup.md"
}

# Run main function
main "$@"