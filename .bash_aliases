# Main bash aliases file
# This file loads all modular alias files from .bash_aliases.d directory
# and specific tool alias files

# Load modular alias files
if [ -d "$HOME/.bash_aliases.d" ]; then
  # Load all .sh files from the directory
  for module in "$HOME/.bash_aliases.d"/*.sh; do
    if [ -f "$module" ]; then
      source "$module"
    fi
  done
fi

# Load specific tool alias files
for alias_file in "$HOME/.bash_aliases."*; do
  if [ -f "$alias_file" ] && [ "$alias_file" != "$HOME/.bash_aliases.d" ]; then
    source "$alias_file"
  fi
done

