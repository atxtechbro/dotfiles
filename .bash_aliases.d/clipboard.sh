#!/bin/bash
# Clipboard management aliases
# Include this file in your .bashrc or .bash_aliases

# Copy command output to clipboard
alias clip-cmd='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | xclip -selection clipboard'

# Quick clipboard access
alias clip="xclip -selection clipboard"

