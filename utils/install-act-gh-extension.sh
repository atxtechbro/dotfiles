#!/bin/bash
# Install act as GitHub CLI extension
# Provides faster feedback loops by running GitHub Actions locally

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_act_gh_extension() {
    echo "Setting up act as GitHub CLI extension..."
    
    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}GitHub CLI (gh) is required but not found${NC}"
        echo "Please install GitHub CLI first or use the standalone act installer"
        return 1
    fi
    
    # Check if act extension is already installed
    if gh extension list | grep -q "nektos/gh-act"; then
        echo -e "${GREEN}✓ act GitHub CLI extension is already installed${NC}"
        return 0
    fi
    
    echo "Installing act as GitHub CLI extension..."
    if gh extension install https://github.com/nektos/gh-act &>/dev/null; then
        echo -e "${GREEN}✓ act GitHub CLI extension installed successfully${NC}"
        return 0
    else
        echo -e "${RED}Failed to install act GitHub CLI extension${NC}"
        return 1
    fi
}

verify_act_gh_extension() {
    if gh extension list | grep -q "nektos/gh-act"; then
        # Test the extension
        if gh act --version &>/dev/null; then
            ACT_VERSION=$(gh act --version 2>/dev/null | head -n1 || echo "unknown")
            echo -e "${GREEN}✓ act GitHub CLI extension is working: ${ACT_VERSION}${NC}"
            
            # Configuration is managed via dotfiles
            echo -e "${GREEN}✓ act configuration managed via dotfiles${NC}"
            echo -e "${BLUE}Configuration file: ~/.config/act/actrc${NC}"
            
            # Check if Docker is available
            if command -v docker &> /dev/null; then
                echo -e "${GREEN}✓ act can use Docker for local GitHub Actions testing${NC}"
                echo -e "${GREEN}Usage: gh act [event] or gh act -l${NC}"
            else
                echo -e "${YELLOW}Docker not found. act requires Docker to run GitHub Actions locally.${NC}"
                echo "Install Docker to use act for local testing."
            fi
            return 0
        else
            echo -e "${RED}act GitHub CLI extension installed but not working properly${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}act GitHub CLI extension installation was attempted but not found${NC}"
        return 1
    fi
}

# Main function to set up act via GitHub CLI extension
setup_act_gh_extension() {
    install_act_gh_extension
    verify_act_gh_extension
}

# If script is run directly (not sourced), execute setup
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_act_gh_extension
fi
