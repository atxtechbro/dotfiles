# macOS-specific aliases and compatibility

# Timeout command compatibility - coreutils provides gtimeout on macOS
if [[ "$OSTYPE" == "darwin"* ]] && command -v gtimeout &> /dev/null && ! command -v timeout &> /dev/null; then
    alias timeout='gtimeout'
fi

# Screenshot management aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Quick access to screenshots folder
    alias screenshots='cd ~/ppv/pillars/dotfiles/screenshots'
    
    # List recent screenshots
    alias recent-screenshots='ls -lat ~/ppv/pillars/dotfiles/screenshots | head -20'
    
    # Reset screenshots to default Desktop location
    alias reset-screenshots='defaults write com.apple.screencapture location ~/Desktop/ && killall SystemUIServer'
    
    # Set screenshots back to dotfiles location
    alias dotfiles-screenshots='defaults write com.apple.screencapture location ~/ppv/pillars/dotfiles/screenshots/ && killall SystemUIServer'
fi
