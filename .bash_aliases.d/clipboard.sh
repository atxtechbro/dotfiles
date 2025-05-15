# Clipboard management aliases
# Include this file in your .bashrc or .bash_aliases

# Copy command output to clipboard
alias clip-cmd='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | xclip -selection clipboard'

# Quick clipboard access
alias clip="xclip -selection clipboard"

# Copy Amazon Q security recommendations to clipboard
# Works with qtrust alias in q-cli.sh for a complete security workflow
qsafe() {
    # Format as a single command with all tools on one line
    echo "/tools untrust fs_write execute_bash use_aws github___create_issue github___add_issue_comment github___push_files github___create_or_update_file github___create_repository gitlab___push_files gitlab___create_or_update_file git___git_commit git___git_add" | xclip -selection clipboard
}

