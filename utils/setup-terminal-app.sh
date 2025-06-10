#!/bin/bash
# Terminal.app Configuration for macOS
# Sets up terminal appearance to match Linux environment

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

setup_terminal_app() {
    echo "Configuring Terminal.app settings..."
    
    # Set larger window size for new windows
    defaults write com.apple.Terminal "NSWindow Frame NSFontPanel" -string "120 40"
    
    # Set larger font size (Monaco 16pt for better readability)
    defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"
    
    # Configure the Pro profile (dark theme) with larger font
    /usr/libexec/PlistBuddy -c "Set :'Window Settings':Pro:Font 'Monaco 16'" ~/Library/Preferences/com.apple.Terminal.plist 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :'Window Settings':Pro:columnCount 120" ~/Library/Preferences/com.apple.Terminal.plist 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :'Window Settings':Pro:rowCount 40" ~/Library/Preferences/com.apple.Terminal.plist 2>/dev/null || true
    
    echo -e "${GREEN}✓ Terminal.app configured with larger window and font${NC}"
    echo -e "${YELLOW}Note: Quit and restart Terminal.app (Cmd+Q then reopen) for changes to take effect${NC}"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_terminal_app
fi
