#!/bin/bash
# GitHub CLI Extensions Installation Utility

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_act_extension() {
    echo "Installing act GitHub CLI extension..."
    
    # Check if act extension is already installed
    if gh extension list | grep -q "nektos/gh-act"; then
        echo -e "${GREEN}✓ act GitHub CLI extension is already installed${NC}"
        return 0
    fi
    
    if gh extension install https://github.com/nektos/gh-act &>/dev/null; then
        echo -e "${GREEN}✓ act GitHub CLI extension installed successfully${NC}"
        
        # Configuration is managed via dotfiles .config/act/actrc
        echo -e "${GREEN}✓ act configuration managed via dotfiles${NC}"
        echo -e "${BLUE}Configuration file: ~/.config/act/actrc${NC}"
        echo -e "${YELLOW}Note: Lightweight images may not work with all actions${NC}"
        
        return 0
    else
        echo -e "${RED}Failed to install act GitHub CLI extension${NC}"
        return 1
    fi
}

setup_gh_extensions() {
    echo "Setting up GitHub CLI extensions..."
    
    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}GitHub CLI (gh) is required but not found${NC}"
        echo "Please install GitHub CLI first"
        return 1
    fi
    
    # Install act extension for local GitHub Actions testing
    install_act_extension || {
        echo -e "${YELLOW}Failed to install act extension, continuing...${NC}"
    }
    
    # Verify installations
    if gh extension list | grep -q "nektos/gh-act"; then
        if gh act --version &>/dev/null; then
            ACT_VERSION=$(gh act --version 2>/dev/null | head -n1 || echo "unknown")
            echo -e "${GREEN}✓ act GitHub CLI extension is working: ${ACT_VERSION}${NC}"
            echo -e "${GREEN}Usage: gh act [event] or gh act -l${NC}"
        fi
    fi
    
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_gh_extensions
fi
