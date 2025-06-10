# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Source the local environment setup
. "$HOME/.local/bin/env"

# Source bash configuration for compatibility (same as Linux systems)
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

# Auto-start tmux if not already in a tmux session and in an interactive shell
if command -v tmux &> /dev/null && [[ $- == *i* ]] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux new-session -A -s main
fi

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
