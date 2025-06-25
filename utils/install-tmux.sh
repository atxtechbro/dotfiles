#!/bin/bash
# tmux Installation and Update Utility
# Handles installation and updates across different operating systems

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_or_update_tmux() {
    echo "Checking tmux installation..."
    
    # Check if tmux is installed
    if command -v tmux &> /dev/null; then
        CURRENT_VERSION=$(tmux -V | cut -d' ' -f2)
        echo "Current tmux version: $CURRENT_VERSION"
        
        # Try to get latest version (this is approximate since tmux doesn't have a simple API)
        # We'll just attempt to update and let the package manager handle version checking
        echo "Attempting to update tmux to latest version..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS with Homebrew
            if command -v brew &> /dev/null; then
                brew upgrade tmux || brew install tmux
                NEW_VERSION=$(tmux -V | cut -d' ' -f2)
                if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
                    echo -e "${GREEN}✓ tmux updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
                else
                    echo -e "${GREEN}✓ tmux is already up to date ($CURRENT_VERSION)${NC}"
                fi
            else
                echo -e "${RED}Homebrew not available, cannot update tmux${NC}"
                return 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux - detect package manager
            if command -v apt &> /dev/null; then
                # Only upgrade if there's actually a newer version available
                if apt list --upgradable 2>/dev/null | grep -q "^tmux/"; then
                    echo "tmux update available, upgrading..."
                    sudo apt update && sudo apt install -y tmux
                else
                    echo -e "${GREEN}✓ tmux is already up to date ($CURRENT_VERSION)${NC}"
                fi
            elif command -v pacman &> /dev/null; then
                sudo pacman -Sy --noconfirm tmux
                NEW_VERSION=$(tmux -V | cut -d' ' -f2)
                if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
                    echo -e "${GREEN}✓ tmux updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
                else
                    echo -e "${GREEN}✓ tmux is already up to date ($CURRENT_VERSION)${NC}"
                fi
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y tmux
                NEW_VERSION=$(tmux -V | cut -d' ' -f2)
                if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
                    echo -e "${GREEN}✓ tmux updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
                else
                    echo -e "${GREEN}✓ tmux is already up to date ($CURRENT_VERSION)${NC}"
                fi
            elif command -v yum &> /dev/null; then
                sudo yum install -y tmux
                NEW_VERSION=$(tmux -V | cut -d' ' -f2)
                if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
                    echo -e "${GREEN}✓ tmux updated from $CURRENT_VERSION to $NEW_VERSION${NC}"
                else
                    echo -e "${GREEN}✓ tmux is already up to date ($CURRENT_VERSION)${NC}"
                fi
            else
                echo -e "${RED}No supported package manager found for tmux installation${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Unsupported OS: $OSTYPE. Cannot update tmux automatically.${NC}"
            return 1
        fi
    else
        echo "tmux not installed. Installing now..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS with Homebrew
            if command -v brew &> /dev/null; then
                brew install tmux
                INSTALLED_VERSION=$(tmux -V | cut -d' ' -f2)
                echo -e "${GREEN}✓ tmux installed successfully (version $INSTALLED_VERSION)${NC}"
            else
                echo -e "${RED}Homebrew not available, cannot install tmux${NC}"
                echo "Please install Homebrew first: https://brew.sh"
                return 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux - detect package manager
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y tmux
            elif command -v pacman &> /dev/null; then
                sudo pacman -Sy --noconfirm tmux
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y tmux
            elif command -v yum &> /dev/null; then
                sudo yum install -y tmux
            else
                echo -e "${RED}No supported package manager found for tmux installation${NC}"
                return 1
            fi
            
            if command -v tmux &> /dev/null; then
                INSTALLED_VERSION=$(tmux -V | cut -d' ' -f2)
                echo -e "${GREEN}✓ tmux installed successfully (version $INSTALLED_VERSION)${NC}"
            else
                echo -e "${RED}tmux installation failed${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Unsupported OS: $OSTYPE. Cannot install tmux automatically.${NC}"
            echo "Please install tmux manually for your system."
            return 1
        fi
    fi
    
    return 0
}

# Main execution
if [[ -n "${BASH_SOURCE[0]}" && "${BASH_SOURCE[0]}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]}" && "$0" != "bash" && "$0" != "zsh" && "$0" != "-bash" && "$0" != "-zsh" ]]; then
    install_or_update_tmux
fi
