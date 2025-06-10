# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Auto-start tmux FIRST, before other configurations
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    exec tmux new-session -A -s main
fi

# Source the local environment setup
. "$HOME/.local/bin/env"

# Source bash configuration for compatibility (same as Linux systems)
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

# Source zsh-specific prompt configuration
if [[ -f ~/.zsh_prompt ]]; then
    source ~/.zsh_prompt
fi

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
