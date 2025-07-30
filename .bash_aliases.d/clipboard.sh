# Clipboard management aliases
# Include this file in your .bashrc or .bash_aliases

# Source the cross-platform clipboard utility
if [[ -f "$HOME/ppv/pillars/dotfiles/utils/clipboard.sh" ]]; then
    source "$HOME/ppv/pillars/dotfiles/utils/clipboard.sh"
fi

# Copy command output to clipboard
alias clip-cmd='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | clipboard_copy'

# Quick clipboard access
alias clip="clipboard_copy"
