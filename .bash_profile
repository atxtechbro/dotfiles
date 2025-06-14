# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.pre.bash"
[[ -f "${HOME}/.local/share/amazon-q/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bash_profile.pre.bash"

# Source .bashrc for login shells (like SSH sessions)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# macOS specific setup (only if files exist)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bash_profile.post.bash"
[[ -f "${HOME}/.local/share/amazon-q/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bash_profile.post.bash"
