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

# Python virtual environment shortcuts
alias venv='[ -d .venv ] || uv venv .venv && source .venv/bin/activate'

# Set library path for llama.cpp
alias set-llama-env='export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/ppv/pipelines/llama.cpp/build/bin'

# Quick AmazonQ.md update workflow - merge, push, and return to main
alias aq-merge='git checkout main && git pull && git merge --squash docs/update-amazonq-guidance && git commit -m "docs(amazonq): update guidance" && git push origin main && echo "✅ AmazonQ.md changes merged and pushed to main"'
# AmazonQ.md update workflow - preserves commit messages from feature branch
alias aq-merge='git checkout main && git pull && git merge docs/update-amazonq-guidance --no-ff && git push origin main && echo "✅ AmazonQ.md changes merged with preserved history and pushed to main"'

# Quick add AmazonQ.md with guidance template - creates a file with standardized guidance I ALWAYS WANT included
alias aq-add='add-amazonq'

# Quick navigation to private P.P.V. repository - personal pillars, pipelines, and vaults
alias ppv='cd ~/ppv'

# mdbook build and serve with automatic port cleanup
# Kills any process using port 3000 before starting mdbook serve
alias mdserve='fuser -k 3000/tcp 2>/dev/null; mdbook build && mdbook serve'

# Llama.cpp local CLI aliases
alias llama='llama-run'
alias lpipe='llama-run -p "$(cat -)"'

# Philips Hue control system alias
alias hue="$HOME/ppv/pipelines/hue_minimal/hue.sh"

# Claude model switch aliases
alias haiku='export ANTHROPIC_MODEL=claude-3-5-haiku-latest'
alias sonnet='export ANTHROPIC_MODEL=claude-3-7-sonnet-latest'
alias opus='export ANTHROPIC_MODEL=claude-3-opus-latest'