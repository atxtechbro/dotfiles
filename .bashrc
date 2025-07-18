# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.pre.bash"
[[ -f "${HOME}/.local/share/amazon-q/shell/bashrc.pre.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bashrc.pre.bash"
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export GPG_TTY=$(tty)
# Note: Removed interactive check to ensure consistent behavior
# across all shell contexts and prevent debugging issues

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
if [ -n "$BASH_VERSION" ]; then
    shopt -s histappend
fi

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
if [ -n "$BASH_VERSION" ]; then
    shopt -s checkwinsize
fi

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "${force_color_prompt:-}" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if [ -n "$BASH_VERSION" ]; then
    if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
    fi
fi
# Git branch in prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYTHONPATH=$PYTHONPATH:$(pwd)

# Bash-specific settings (only in interactive shells)
if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
    bind 'set enable-bracketed-paste off'
fi

if [ -f ~/.bash_exports ]; then
    . ~/.bash_exports
fi

# Load secrets file if it exists
if [ -f ~/.bash_secrets ]; then
    . ~/.bash_secrets
fi

DOT_DEN="$HOME/ppv/pillars/dotfiles"

# Add your scripts directory to the PATH
export PATH="$DOT_DEN/bin:$PATH"

# Skip auto-tmux and directory change for SSH connections
if [[ -n "${SSH_CONNECTION:-}" ]]; then
    # When connecting via SSH, don't auto-change directory or start tmux
    # This prevents recursive loops when connecting to localhost
    :
else
    # Only change to dotfiles directory when NOT in a tmux session (only in interactive shells)
    if [[ $- == *i* ]] && [ -z "$TMUX" ] && [ -d "$DOT_DEN" ]; then
        cd "$DOT_DEN" || true
    fi

    # Source Amazon Q environment if installed
    if [ -f "$HOME/.local/bin/env" ]; then
        . "$HOME/.local/bin/env"
    fi

    # Auto-start tmux with a unique session name based on timestamp
    # Skip auto-start if we're running from the setup script
    # Also skip if we're running a navigation alias (to prevent session termination)
    if [ -z "$TMUX" ] && [[ "$-" == *i* ]] && command -v tmux >/dev/null 2>&1 && [ -z "$SETUP_SCRIPT_RUNNING" ] && [ -z "$NAVIGATION_ALIAS_RUNNING" ]; then
        # Create a new session with a unique name (terminal-TIMESTAMP)
        SESSION_NAME="terminal-$(date +%s)"
        exec tmux new-session -s "$SESSION_NAME"
    fi
fi

# Reload tmux configuration whenever bashrc is sourced
# This ensures tmux always has the latest config when started
tmux source-file ~/.tmux.conf >/dev/null 2>&1 || true

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/amazon-q/shell/bashrc.post.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bashrc.post.bash"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/uv-tools/bin:$PATH"

# Set prompt to show current directory and git branch (bash only)
if [ -n "$BASH_VERSION" ]; then
    PS1='\W\[\033[32m\]$(parse_git_branch)\[\033[00m\] \$ '
fi

# Platform-specific PATH additions
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/Users/$(whoami)/.local/bin:$PATH"

# Auto-navigate to dotfiles directory on new shell (only in interactive shells)
if [[ $- == *i* ]] && [[ -d "$HOME/ppv/pillars/dotfiles" && "$PWD" == "$HOME" ]]; then
    cd "$HOME/ppv/pillars/dotfiles" || true
fi

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/bashrc.post.bash"
[[ -f "${HOME}/.local/share/amazon-q/shell/bashrc.post.bash" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/bashrc.post.bash"
