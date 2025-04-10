alias grabout='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | xclip -selection clipboard'
alias grabout='echo -n "$(fc -s -1)" | xclip -in -selection clipboard && echo "Last command copied!"'
alias clip='xclip -selection clipboard'
alias git-tree="git ls-tree -r HEAD --name-only | tree --fromfile"
alias gha-fails='get-latest-failed-gha-logs.sh'

# Source bashrc quickly with a short alias
alias src='source ~/.bashrc'

# GitHub PR metadata quick view
alias prv='gh pr view --json number,title,state,url,author,createdAt,updatedAt,mergeable,reviewDecision'

# PR stats with detailed information including additions, deletions, and files
alias pr-stats='gh pr view --json additions,deletions,changedFiles,files,title,state,url'
alias pr-stats-full='gh pr view --json additions,deletions,changedFiles,files,title,author,state,createdAt,updatedAt,url,assignees,body,closed,closedAt,comments,commits,headRefName,headRefOid,isDraft,labels,mergeStateStatus,mergeable,mergedAt,mergedBy,reviewDecision,reviews'

# Tmux config comparison aliases - toggle between branches like at the optometrist
alias tmux-main="git checkout main && tmux source-file ~/.tmux.conf && echo 'Switched to main branch config'"
alias tmux-pr="git checkout - && tmux source-file ~/.tmux.conf && echo 'Switched to branch: $(git branch --show-current)'"

# Tmux cheatsheet quick access
alias tmux-help="less ~/dotfiles/tmux-cheatsheet.md"

