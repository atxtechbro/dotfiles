#!/bin/bash
# Tmux related aliases
# Include this file in your .bashrc or .bash_aliases

# Switch to main branch and reload tmux config
alias tmux-main="git checkout main && tmux source-file ~/.tmux.conf && echo 'Switched to main branch config'"

# Switch to previous branch and reload tmux config
alias tmux-branch='git checkout - && tmux source-file ~/.tmux.conf && echo "Switched to branch: $(git branch --show-current)"'

# Quick access to tmux cheatsheet
alias tmux-help="less ~/dotfiles/tmux-cheatsheet.md"

