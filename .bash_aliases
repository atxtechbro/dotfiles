alias grabout='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | xclip -selection clipboard'
alias grabout='echo -n "$(fc -s -1)" | xclip -in -selection clipboard && echo "Last command copied!"'
alias clip='xclip -selection clipboard'
alias git-tree="git ls-tree -r HEAD --name-only | tree --fromfile"
alias gha-fails='get-latest-failed-gha-logs.sh'

# Tmux config comparison aliases - toggle between branches like at the optometrist
alias tmux-main="gh pr checkout main && tmux source-file ~/.tmux.conf"
alias tmux-pr="gh pr checkout - && tmux source-file ~/.tmux.conf"

