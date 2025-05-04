# Main bash aliases file
# This file loads all modular alias files from .bash_aliases.d directory

# Load modular alias files - explicitly source each file to avoid glob issues
if [ -d "$HOME/.bash_aliases.d" ]; then
  # Source each file individually to avoid glob expansion issues
  for module in clipboard claude git github llama misc nav python q-cli tmux; do
    if [ -f "$HOME/.bash_aliases.d/$module.sh" ]; then
      source "$HOME/.bash_aliases.d/$module.sh"
    fi
  done
fi
