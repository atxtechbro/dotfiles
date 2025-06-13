#!/bin/bash

# =========================================================
# ITERM2 TMUX CONFIGURATION
# =========================================================
# PURPOSE: Configure iTerm2 for optimal tmux integration
# Following the "Spilled Coffee Principle" - declarative configuration
# This ensures Option keys work properly with tmux Meta key bindings
# =========================================================

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

configure_iterm2_tmux_integration() {
    echo -e "${BLUE}Configuring iTerm2 for tmux integration...${NC}"
    
    # Check if iTerm2 is installed
    if [ ! -d "/Applications/iTerm.app" ]; then
        echo -e "${YELLOW}iTerm2 not found - skipping configuration${NC}"
        return 0
    fi
    
    # Configure Option keys to send Esc+ sequences for tmux Meta bindings
    # This enables Alt-h/j/k/l navigation in tmux without prefix
    echo -e "${BLUE}Setting Option keys to send escape sequences...${NC}"
    
    # Left Option Key: Esc+ (value 2)
    defaults write com.googlecode.iterm2 "LeftOptionKey" -int 2
    
    # Right Option Key: Esc+ (value 2) 
    defaults write com.googlecode.iterm2 "RightOptionKey" -int 2
    
    # Configure default profile for new sessions
    # Get the current default profile GUID
    DEFAULT_PROFILE=$(defaults read com.googlecode.iterm2 "Default Bookmark Guid" 2>/dev/null || echo "")
    
    if [ -n "$DEFAULT_PROFILE" ]; then
        echo -e "${BLUE}Updating default profile settings...${NC}"
        # Update the specific profile's Option key behavior
        defaults write com.googlecode.iterm2 "New Bookmarks" -array-add "{
            \"Guid\" = \"$DEFAULT_PROFILE\";
            \"Option Key Sends\" = 2;
        }" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ iTerm2 configured for tmux integration${NC}"
    echo -e "${YELLOW}Note: iTerm2 restart required for changes to take effect${NC}"
    
    return 0
}

# Validate current configuration
validate_iterm2_config() {
    if [ ! -d "/Applications/iTerm.app" ]; then
        return 0
    fi
    
    LEFT_OPTION=$(defaults read com.googlecode.iterm2 "LeftOptionKey" 2>/dev/null || echo "0")
    RIGHT_OPTION=$(defaults read com.googlecode.iterm2 "RightOptionKey" 2>/dev/null || echo "0")
    
    if [ "$LEFT_OPTION" = "2" ] && [ "$RIGHT_OPTION" = "2" ]; then
        echo -e "${GREEN}✓ iTerm2 already configured for tmux${NC}"
        return 0
    else
        echo -e "${YELLOW}iTerm2 needs configuration for tmux integration${NC}"
        return 1
    fi
}

# Main execution
main() {
    if validate_iterm2_config; then
        return 0
    else
        configure_iterm2_tmux_integration
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
