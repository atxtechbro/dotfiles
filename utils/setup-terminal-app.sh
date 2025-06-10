#!/bin/bash
# Terminal.app Configuration for macOS
# Sets up terminal appearance to match Linux environment

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

setup_terminal_app() {
    echo "Configuring Terminal.app settings..."
    
    # Create a new terminal profile called "Dotfiles"
    PROFILE_NAME="Dotfiles"
    
    # Set terminal window size (larger, like Linux)
    defaults write com.apple.Terminal "Window Settings" -dict-add "$PROFILE_NAME" '{
        "columnCount" = 120;
        "rowCount" = 40;
    }'
    
    # Set dark background and remove borders
    defaults write com.apple.Terminal "Window Settings" -dict-add "$PROFILE_NAME" '{
        "BackgroundColor" = "0.0 0.0 0.0 1.0";
        "TextColor" = "1.0 1.0 1.0 1.0";
        "CursorColor" = "1.0 1.0 1.0 1.0";
        "SelectionColor" = "0.3 0.3 0.3 1.0";
        "BackgroundBlur" = 0;
        "BackgroundSettingsForInactiveWindows" = 0;
    }'
    
    # Set font size (larger for better readability)
    defaults write com.apple.Terminal "Window Settings" -dict-add "$PROFILE_NAME" '{
        "Font" = "Monaco 14";
    }'
    
    # Remove window decorations and set as default
    defaults write com.apple.Terminal "Default Window Settings" "$PROFILE_NAME"
    defaults write com.apple.Terminal "Startup Window Settings" "$PROFILE_NAME"
    
    echo -e "${GREEN}✓ Terminal.app configured with Dotfiles profile${NC}"
    echo -e "${YELLOW}Note: You may need to restart Terminal.app for all changes to take effect${NC}"
    echo -e "${YELLOW}Go to Terminal > Preferences > Profiles to select the 'Dotfiles' profile${NC}"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_terminal_app
fi
