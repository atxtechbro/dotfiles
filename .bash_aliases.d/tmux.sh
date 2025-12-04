# Tmux related aliases
# Include this file in your .bashrc or .bash_aliases

# Switch to main branch and reload tmux config
alias tmux-main="git checkout main && tmux source-file ~/.tmux.conf && echo 'Switched to main branch config'"

# Switch to previous branch and reload tmux config
alias tmux-branch='git checkout - && tmux source-file ~/.tmux.conf && echo "Switched to branch: $(git branch --show-current)"'

# Quick access to tmux cheatsheet
alias tmux-help="less ~/dotfiles/tmux-cheatsheet.md"

# Copy full history from the current (or last) pane to system clipboard
tmux_copy_history() {
    local target_pane

    # If we're inside tmux, use the active pane; otherwise fall back to the last active pane
    if [ -n "$TMUX" ]; then
        target_pane="$(tmux display-message -p '#{pane_id}')"
    else
        target_pane="$(tmux display-message -p -F '#{pane_id}' -t '{last}')"
    fi

    tmux capture-pane -p -J -S -999999 -t "${target_pane}" | clipboard_copy
}
alias tmux-copy-history='tmux_copy_history'
