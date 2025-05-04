# Main bash aliases file
# This file loads all modular alias files

# Load modular alias files
for alias_file in ~/.bash_aliases.*; do
  if [ -f "$alias_file" ]; then
    source "$alias_file"
  fi
done
