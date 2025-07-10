#!/bin/bash
# Install AWS CLI v2
set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Checking AWS CLI installation...${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get current AWS CLI version
get_aws_version() {
    if command_exists aws; then
        aws --version 2>/dev/null | awk '{print $1}' | cut -d'/' -f2
    else
        echo "0"
    fi
}

# Function to compare versions
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Main installation function
install_aws_cli() {
    local os_type="$(uname -s)"
    
    case "$os_type" in
        Darwin)
            install_aws_cli_macos
            ;;
        Linux)
            install_aws_cli_linux
            ;;
        *)
            echo -e "${RED}Unsupported operating system: $os_type${NC}"
            return 1
            ;;
    esac
}

# macOS installation
install_aws_cli_macos() {
    echo -e "${BLUE}Installing AWS CLI for macOS...${NC}"
    
    # Check if Homebrew is available
    if command_exists brew; then
        echo "Using Homebrew to install AWS CLI..."
        brew install awscli
    else
        # Manual installation for macOS
        echo "Installing AWS CLI manually..."
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        # Download AWS CLI
        curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
        
        # Install the package
        sudo installer -pkg AWSCLIV2.pkg -target /
        
        # Cleanup
        cd - >/dev/null 2>&1
        rm -rf "$temp_dir"
    fi
}

# Linux installation
install_aws_cli_linux() {
    echo -e "${BLUE}Installing AWS CLI for Linux...${NC}"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Detect architecture
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    elif [[ "$arch" == "aarch64" ]]; then
        curl -s "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    else
        echo -e "${RED}Unsupported architecture: $arch${NC}"
        cd - >/dev/null 2>&1
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Unzip and install
    unzip -q awscliv2.zip
    sudo ./aws/install --update
    
    # Cleanup
    cd - >/dev/null 2>&1
    rm -rf "$temp_dir"
}

# Update AWS CLI if needed
update_aws_cli() {
    echo -e "${BLUE}Checking for AWS CLI updates...${NC}"
    
    # Skip update check - just report current version
    local current_version=$(get_aws_version)
    echo -e "${GREEN}✓ AWS CLI version $current_version${NC}"
    
    # Don't do automatic updates - they can be disruptive
    return 0
}

# Main execution
main() {
    if command_exists aws; then
        local current_version=$(get_aws_version)
        echo -e "${GREEN}✓ AWS CLI is already installed (version $current_version)${NC}"
        
        # Check for updates
        update_aws_cli
    else
        echo -e "${YELLOW}AWS CLI not found. Installing...${NC}"
        install_aws_cli
        
        # Verify installation
        if command_exists aws; then
            local version=$(get_aws_version)
            echo -e "${GREEN}✓ AWS CLI installed successfully (version $version)${NC}"
        else
            echo -e "${RED}Failed to install AWS CLI${NC}"
            return 1
        fi
    fi
    
    # Verify AWS CLI is in PATH
    if ! command_exists aws; then
        echo -e "${YELLOW}AWS CLI installed but not in PATH${NC}"
        echo "You may need to add it to your PATH or restart your shell"
    fi
}

# Export function for sourcing
setup_aws_cli() {
    main "$@"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi