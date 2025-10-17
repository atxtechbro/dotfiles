# Amazon Q CLI - Development aliases
# Include this file in your .bashrc or .bash_aliases

# Build Amazon Q CLI from source
alias q-build="cd $HOME/ppv/pillars/q-cli && cargo build --release"

# Run the compiled release version
alias q-run="$HOME/ppv/pillars/q-cli/target/release/q"

# Quick development testing (build and run in one step)
alias q-dev="cd $HOME/ppv/pillars/q-cli && cargo run --bin q_cli -- chat"


# Amazon Q alias with auto-trust (simplified setup)
alias q='q chat /tools trustall'

# Test command - validates knowledge integration
alias q-test='q chat --prompt "What is AI harness agnosticism and which development harnesses support dual redundancy?"'

