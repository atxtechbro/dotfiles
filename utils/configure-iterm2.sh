#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

configure_iterm2() {
    echo "Configuring iTerm2 preferences..."
    
    echo "Resetting iTerm2 configuration for reproducibility..."
    defaults delete com.googlecode.iterm2 2>/dev/null || true
    
    defaults write com.googlecode.iterm2 "New Bookmarks" -array '{
        "Name" = "Default";
        "Guid" = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F";
        "Columns" = 120;
        "Rows" = 40;
        "Default Bookmark" = "Yes";
        "Normal Font" = "Monaco 15";
        "Non Ascii Font" = "Monaco 15";
    }'
    
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
    
    defaults write com.googlecode.iterm2 "LeftOptionKey" -int 2
    defaults write com.googlecode.iterm2 "RightOptionKey" -int 2
    
    defaults write com.googlecode.iterm2 "WindowStyle" -int 0
    defaults write com.googlecode.iterm2 "UseBorder" -bool false
    
    echo -e "${GREEN}✓ iTerm2 configured with 120x40 window and Monaco 15pt font${NC}"
    
    if pgrep -x "iTerm2" > /dev/null; then
        echo -e "${YELLOW}iTerm2 restart required for changes to take effect${NC}"
    fi
    
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_iterm2
fi
