# Tmux related aliases
# Include this file in your .bashrc or .bash_aliases

# Switch to main branch and reload tmux config
alias tmux-main="git checkout main && tmux source-file ~/.tmux.conf && echo 'Switched to main branch config'"

# Switch to previous branch and reload tmux config
alias tmux-branch='git checkout - && tmux source-file ~/.tmux.conf && echo "Switched to branch: $(git branch --show-current)"'

# Quick access to tmux cheatsheet
alias tmux-help="less ~/dotfiles/tmux-cheatsheet.md"

# Copy visible history from the active (or last) pane to the system clipboard
tmux_copy_history() {
    local target_pane

    if [ -n "$TMUX" ]; then
        target_pane="$(tmux display-message -p '#{pane_id}')"
    else
        if ! target_pane="$(tmux display-message -p -F '#{pane_id}' -t '{last}' 2>/dev/null)"; then
            echo "tmux-copy-history: no tmux session found" >&2
            return 1
        fi
    fi

    # -S -0 captures from the top of the visible pane (respects a recent clear)
    tmux capture-pane -p -J -S -0 -t "${target_pane}" | clipboard_copy
}
alias tmux-copy-history='tmux_copy_history'
