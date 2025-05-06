#!/bin/bash
# Git related aliases
# Include this file in your .bashrc or .bash_aliases

# Display git repository file structure as a tree
alias git-tree="git ls-tree -r HEAD --name-only | tree --fromfile"

# Get latest failed GitHub Actions logs
alias git-gha-fails="get-latest-failed-gha-logs.sh"

