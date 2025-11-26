# Clipboard management aliases
# Include this file in your .bashrc or .bash_aliases
# DOT_DEN is set by .bash_exports (loaded before aliases in .bashrc)

# Source the cross-platform clipboard utility
if [[ -f "$DOT_DEN/utils/clipboard.sh" ]]; then
    source "$DOT_DEN/utils/clipboard.sh"
fi

# Copy command output to clipboard
alias clip-cmd='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | clipboard_copy'

# Quick clipboard access
alias clip="clipboard_copy"
