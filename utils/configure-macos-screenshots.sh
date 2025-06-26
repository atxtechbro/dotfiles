#!/bin/bash
# Configure macOS screenshot location to use dotfiles/screenshots directory

# Source common functions and variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_DEN="${DOT_DEN:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Define colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

configure_screenshots() {
    # Only run on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${YELLOW}This script only applies to macOS. Skipping...${NC}"
        return 0
    fi
    
    echo "Configuring macOS screenshot location..."
    
    # Create screenshots directory if it doesn't exist
    SCREENSHOTS_DIR="$DOT_DEN/screenshots"
    if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
        mkdir -p "$SCREENSHOTS_DIR"
        echo -e "${GREEN}✓ Created screenshots directory at $SCREENSHOTS_DIR${NC}"
    else
        echo -e "${GREEN}✓ Screenshots directory already exists at $SCREENSHOTS_DIR${NC}"
    fi
    
    # Set macOS default screenshot location
    defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
    
    # Restart SystemUIServer to apply changes
    killall SystemUIServer 2>/dev/null || true
    
    echo -e "${GREEN}✓ macOS screenshots will now be saved to: $SCREENSHOTS_DIR${NC}"
    echo -e "${BLUE}Note: Screenshots are gitignored for privacy/security${NC}"
    
    return 0
}

# Run the configuration if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_screenshots
fi