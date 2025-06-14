# Amazon Q pre block. Keep at the top of this file.
# Platform-specific Amazon Q paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS path
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
else
    # Linux path
    [[ -f "${HOME}/.local/share/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/zshrc.pre.zsh"
fi

# Auto-start tmux FIRST, before other configurations
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    exec tmux new-session -A -s main
fi

# Platform-specific environment setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific setup
    if [ -f "$HOME/.local/bin/env" ]; then
        . "$HOME/.local/bin/env"
    fi
fi

# Source bash configuration for compatibility (same as Linux systems)
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

# Source zsh-specific prompt configuration
if [[ -f ~/.zsh_prompt ]]; then
    source ~/.zsh_prompt
fi

# Amazon Q post block. Keep at the bottom of this file.
# Platform-specific Amazon Q paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS path
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
else
    # Linux path
    [[ -f "${HOME}/.local/share/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/zshrc.post.zsh"
fi
