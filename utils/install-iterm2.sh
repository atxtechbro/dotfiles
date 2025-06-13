#!/bin/bash
# iTerm2 Installation and Configuration Utility
# Better terminal for macOS development

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_and_configure_iterm2() {
    echo "Setting up iTerm2..."
    
    # Check if iTerm2 is already installed
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
    
    # Configure iTerm2 preferences
    echo "Configuring iTerm2 preferences..."
    
    # Set reasonable default window size (not postage stamp size)
    defaults write com.googlecode.iterm2 "New Bookmarks" -array-add '{
        "Columns" = 120;
        "Rows" = 40;
    }'
    
    # Configure Option key behavior for tmux navigation
    # Set Left Option Key to Esc+ (Meta) for tmux pane navigation
    defaults write com.googlecode.iterm2 "LeftOptionKey" -int 3
    # Set Right Option Key to Esc+ (Meta) as well
    defaults write com.googlecode.iterm2 "RightOptionKey" -int 3
    
    # Set larger default window size
    defaults write com.googlecode.iterm2 "New Bookmarks" -array-add '{
        "Name" = "Dotfiles";
        "Columns" = 120;
        "Rows" = 40;
        "Normal Font" = "Monaco 16";
        "Background Color" = {
            "Red Component" = 0.043137254901960784;
            "Green Component" = 0.043137254901960784;
            "Blue Component" = 0.043137254901960784;
        };
        "Foreground Color" = {
            "Red Component" = 1;
            "Green Component" = 1;
            "Blue Component" = 1;
        };
        "Option Key Sends" = 2;
    }'
    
    # Set as default profile
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "Dotfiles"
    
    echo -e "${GREEN}✓ iTerm2 configured with developer-friendly settings${NC}"
    echo -e "${YELLOW}Note: Launch iTerm2 to use the new terminal with larger window and better font${NC}"
    echo -e "${YELLOW}You can set iTerm2 as your default terminal in System Preferences${NC}"
    echo -e "${YELLOW}Option+h/j/k/l should now work for tmux pane navigation${NC}"
    
    # Apply settings immediately if iTerm2 is running
    if pgrep -x "iTerm2" > /dev/null; then
        echo -e "${YELLOW}iTerm2 is running - restart iTerm2 for Option key changes to take effect${NC}"
    fi
    
    return 0
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_and_configure_iterm2
fi
