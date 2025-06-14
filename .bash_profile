# Amazon Q pre block. Keep at the top of this file.
# Platform-specific Amazon Q paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS path
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.pre.bash"
else
    # Linux path
    [[ -f "${HOME}/.local/share/amazon-q/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bash_profile.pre.bash"
fi

# Source .bashrc for login shells (like SSH sessions)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Platform-specific environment setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific setup
    if [ -f "$HOME/.local/bin/env" ]; then
        . "$HOME/.local/bin/env"
    fi
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Amazon Q post block. Keep at the bottom of this file.
# Platform-specific Amazon Q paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS path
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.post.bash"
else
    # Linux path
    [[ -f "${HOME}/.local/share/amazon-q/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bash_profile.post.bash"
fi
