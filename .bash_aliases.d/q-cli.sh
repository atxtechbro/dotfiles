# Amazon Q CLI - Development aliases
# Include this file in your .bashrc or .bash_aliases

# Build Amazon Q CLI from source
alias q-build="cd $HOME/ppv/pillars/q-cli && cargo build --release"

# Run the compiled release version
alias q-run="$HOME/ppv/pillars/q-cli/target/release/q"

# Quick development testing (build and run in one step)
alias q-dev="cd $HOME/ppv/pillars/q-cli && cargo run --bin q_cli -- chat"

# Amazon Q documentation workflow
alias q-doc-merge="git checkout main && git pull && git merge docs/update-amazonq-guidance --no-ff && git push origin main && echo '✅ AmazonQ.md changes merged with preserved history and pushed to main'"
alias q-doc-add="add-amazonq"

# Main Amazon Q command with resume and aliases loaded
alias qq='source ~/.bash_aliases && q chat --resume'

# Fresh Amazon Q session (no resume) - use when you want a clean start
alias qf='source ~/.bash_aliases && q chat'

# Trust all tools command
# Use with qsafe alias from clipboard.sh for a complete security workflow
qtrust() {
    q chat "$@" "/tools trustall"
}



