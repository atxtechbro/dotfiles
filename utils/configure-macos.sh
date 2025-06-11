#!/bin/bash
# macOS System Configuration
# Automated settings for consistent macOS environment

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Configuring macOS system settings...${NC}"

# Configure iTerm2 as default terminal
echo "Configuring iTerm2 as default terminal..."
defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType="public.unix-executable";LSHandlerRoleAll="com.googlecode.iterm2";}'
echo -e "${GREEN}✓ iTerm2 configured as default terminal${NC}"

# Disable iTerm2 quit confirmation dialog (prevents cron shutdown issues)
echo "Disabling iTerm2 quit confirmation dialog..."
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
defaults write com.googlecode.iterm2 OnlyWhenMoreTabs -bool false
echo -e "${GREEN}✓ iTerm2 quit confirmation disabled${NC}"

# Additional macOS system preferences can be added here
# Examples:
# - Dock settings
# - Finder preferences  
# - Keyboard/trackpad settings
# - Security settings

echo -e "${GREEN}✓ macOS configuration complete${NC}"
