# Main bash aliases file
# This file loads all modular alias files from .bash_aliases.d directory

# Load modular alias files
if [ -d "$HOME/.bash_aliases.d" ]; then
  for alias_file in "$HOME/.bash_aliases.d"/*.sh; do
    if [ -f "$alias_file" ]; then
      source "$alias_file"
    fi
  done
fi
