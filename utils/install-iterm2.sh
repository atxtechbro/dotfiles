#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

install_iterm2() {
    echo "Setting up iTerm2..."
    
    if [ -d "/Applications/iTerm.app" ]; then
        echo -e "${GREEN}✓ iTerm2 is already installed${NC}"
    else
        echo "Installing iTerm2..."
        if command -v brew &> /dev/null; then
            brew install --cask iterm2
            echo -e "${GREEN}✓ iTerm2 installed successfully${NC}"
        else
            echo -e "${RED}Homebrew not available, cannot install iTerm2${NC}"
            echo "Please install iTerm2 manually from https://iterm2.com"
            return 1
        fi
    fi
    
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_iterm2
fi
