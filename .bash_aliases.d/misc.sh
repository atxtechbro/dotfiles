# Miscellaneous aliases
# Include this file in your .bashrc or .bash_aliases

# Source bashrc quickly with a short alias
alias src="source ~/.bashrc"

# mdbook build and serve with automatic port cleanup
alias mdbook-serve="fuser -k 3000/tcp 2>/dev/null; mdbook build && mdbook serve"

# Philips Hue control system
alias hue="$HOME/ppv/pipelines/hue_minimal/hue.sh"
