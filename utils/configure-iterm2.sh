#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Declarative iTerm2 configuration optimized for tmux + Amazon Q CLI workflow
ITERM2_TMUX_CONFIG='{
    "profile": {
        "Name": "TmuxDev",
        "Guid": "TMUX-DEV-WORKFLOW-2024",
        "Columns": 140,
        "Rows": 45,
        "Default Bookmark": "Yes",
        "Normal Font": "Monaco 14",
        "Non Ascii Font": "Monaco 14",
        "Scrollback Lines": -1,
        "Unlimited Scrollback": true,
        "Terminal Type": "xterm-256color"
    },
    "global": {
        "Default Bookmark Guid": "TMUX-DEV-WORKFLOW-2024",
        "LeftOptionKey": 2,
        "RightOptionKey": 2,
        "WindowStyle": 0,
        "UseBorder": false,
        "HideTab": true,
        "ShowWindowNumber": false
    }
}'

configure_iterm2() {
    echo "Configuring iTerm2 for tmux + Amazon Q CLI workflow..."
    
    echo "Resetting iTerm2 configuration for reproducibility..."
    defaults delete com.googlecode.iterm2 2>/dev/null || true
    
    defaults write com.googlecode.iterm2 "New Bookmarks" -array '{
        "Name" = "TmuxDev";
        "Guid" = "TMUX-DEV-WORKFLOW-2024";
        "Columns" = 140;
        "Rows" = 45;
        "Default Bookmark" = "Yes";
        "Normal Font" = "Monaco 14";
        "Non Ascii Font" = "Monaco 14";
        "Scrollback Lines" = -1;
        "Unlimited Scrollback" = 1;
        "Terminal Type" = "xterm-256color";
    }'
    
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "TMUX-DEV-WORKFLOW-2024"
    defaults write com.googlecode.iterm2 "LeftOptionKey" -int 2
    defaults write com.googlecode.iterm2 "RightOptionKey" -int 2
    defaults write com.googlecode.iterm2 "WindowStyle" -int 0
    defaults write com.googlecode.iterm2 "UseBorder" -bool false
    
    echo -e "${GREEN}✓ iTerm2 configured for tmux workflow (140x45, Monaco 14pt)${NC}"
    
    if pgrep -x "iTerm2" > /dev/null; then
        echo -e "${YELLOW}iTerm2 restart required for changes to take effect${NC}"
    fi
    
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_iterm2
fi
