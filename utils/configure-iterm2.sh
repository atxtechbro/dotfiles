#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

configure_iterm2() {
    echo "Configuring iTerm2 for tmux + Amazon Q CLI workflow..."
    
    # Get the directory where this script is located
    # When sourced from setup.sh, we need to use DOT_DEN
    if [[ -n "$DOT_DEN" ]]; then
        SCRIPT_DIR="$DOT_DEN/utils"
    else
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    fi
    
    # Check if we have the preferences template
    if [[ -f "$SCRIPT_DIR/iterm2-preferences.plist" ]]; then
        echo "Applying iTerm2 preferences from template..."
        
        # Backup current preferences
        if [[ -f ~/Library/Preferences/com.googlecode.iterm2.plist ]]; then
            cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.backup
            echo "Backed up current preferences to ~/Library/Preferences/com.googlecode.iterm2.plist.backup"
        fi
        
        # Apply our preferences
        cp "$SCRIPT_DIR/iterm2-preferences.plist" ~/Library/Preferences/com.googlecode.iterm2.plist
        
        # Force preferences daemon to reload
        killall cfprefsd 2>/dev/null || true
        
        echo -e "${GREEN}✓ iTerm2 configured with tmux-optimized settings (mouse reporting enabled, 140x45, Monaco 14pt)${NC}"
    else
        echo -e "${YELLOW}Warning: iTerm2 preferences template not found at $SCRIPT_DIR/iterm2-preferences.plist${NC}"
        echo "To create one: Run 'defaults read com.googlecode.iterm2 > $SCRIPT_DIR/iterm2-preferences.plist' with your preferred settings"
        return 1
    fi
    
    if pgrep -x "iTerm2" > /dev/null; then
        echo -e "${YELLOW}⚠️  iTerm2 MUST be restarted for changes to take effect${NC}"
        echo -e "${YELLOW}   (Unlike manual preference changes, programmatic changes require a restart)${NC}"
        echo ""
        echo "To restart iTerm2:"
        echo "  1. Quit iTerm2 completely (Cmd+Q)"
        echo "  2. Reopen iTerm2"
        echo ""
        echo "Or run: osascript -e 'quit app \"iTerm2\"' && sleep 2 && open -a iTerm2"
    fi
    
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_iterm2
fi