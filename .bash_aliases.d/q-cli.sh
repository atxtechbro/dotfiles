# Amazon Q CLI - Development aliases and functions
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

# Amazon Q with trust setup - using process substitution design pattern
# Process substitution (<(...)) creates a temporary file-like object containing our commands
# This allows us to feed multiple commands to Amazon Q while keeping the session interactive
alias qtrust='q chat < <(echo -e "/tools trustall\n/tools untrust fs_write execute_bash use_aws")'
