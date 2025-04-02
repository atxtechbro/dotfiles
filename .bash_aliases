alias grabout='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | xclip -selection clipboard'
alias grabout='echo -n "$(fc -s -1)" | xclip -in -selection clipboard && echo "Last command copied!"'
alias clip='xclip -selection clipboard'
alias git-tree='if git rev-parse --is-inside-work-tree &>/dev/null; then git ls-tree -r HEAD --name-only | tree --fromfile; else echo "Not in a git repository"; fi'
alias gha-fails='get-latest-failed-gha-logs.sh'

# Tmux config comparison aliases - toggle between branches like at the optometrist
alias tmux-main="cd ~/dotfiles && git checkout main && tmux source-file ~/.tmux.conf && echo 'Switched to main branch config'"
alias tmux-pr="cd ~/dotfiles && git checkout - && tmux source-file ~/.tmux.conf && echo 'Switched to branch: $(git branch --show-current)'"

# Tmux cheatsheet quick access
alias tmux-help="less ~/dotfiles/tmux-cheatsheet.md"

