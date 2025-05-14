# Main bash aliases file
# This file loads all modular alias files from .bash_aliases.d directory

# Load modular alias files
if [ -d "$HOME/.bash_aliases.d" ]; then
  # Load all .sh files from the directory
  for module in "$HOME/.bash_aliases.d"/*.sh; do
    if [ -f "$module" ]; then
      source "$module"
    fi
  done
fi
