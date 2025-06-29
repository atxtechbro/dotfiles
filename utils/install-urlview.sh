#!/bin/bash
# urlview Installation Utility
# URL extraction tool for tmux - implements "stand on the shoulders of giants" principle
# Provides cross-platform solution for extracting URLs from terminal output

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_or_update_urlview() {
    echo "Checking urlview installation (URL extraction utility for tmux)..."
    
    # Check if urlview is installed
    if command -v urlview &> /dev/null; then
        echo -e "${GREEN}✓ urlview is already installed${NC}"
        return 0
    else
        echo "urlview not installed. Installing now..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS with Homebrew
            if command -v brew &> /dev/null; then
                brew install urlview
                if command -v urlview &> /dev/null; then
                    echo -e "${GREEN}✓ urlview installed successfully${NC}"
                    echo "Use 'prefix + u' in tmux to extract URLs from current pane"
                else
                    echo -e "${RED}urlview installation failed${NC}"
                    return 1
                fi
            else
                echo -e "${RED}Homebrew not available, cannot install urlview${NC}"
                echo "Please install Homebrew first: https://brew.sh"
                return 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux - detect package manager
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y urlview
            elif command -v pacman &> /dev/null; then
                sudo pacman -Sy --noconfirm urlview
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y urlview
            elif command -v yum &> /dev/null; then
                sudo yum install -y urlview
            else
                echo -e "${RED}No supported package manager found for urlview installation${NC}"
                return 1
            fi
            
            if command -v urlview &> /dev/null; then
                echo -e "${GREEN}✓ urlview installed successfully${NC}"
                echo "Use 'prefix + u' in tmux to extract URLs from current pane"
            else
                echo -e "${RED}urlview installation failed${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Unsupported OS: $OSTYPE. Cannot install urlview automatically.${NC}"
            echo "Please install urlview manually for your system."
            return 1
        fi
    fi
    
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_or_update_urlview
fi