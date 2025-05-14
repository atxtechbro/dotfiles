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

# Function to run Amazon Q with trust permissions setup
function q() {
  # Only run setup if this is an interactive chat session
  if [[ "$1" == "chat" && "$2" != "--no-interactive" ]]; then
    # Create a temporary script file with commands to run at startup
    STARTUP_SCRIPT=$(mktemp)
    cat > "$STARTUP_SCRIPT" << EOF
/tools trustall
/tools untrust execute_bash use_aws fs_write
EOF
    
    # Launch Amazon Q with the startup script
    echo "Launching Amazon Q with trust setup..."
    command q chat --startup-commands-file "$STARTUP_SCRIPT"
    
    # Clean up
    rm "$STARTUP_SCRIPT"
    return
  fi
  
  # For all other commands, just pass through
  command q "$@"
}

# Export the function
export -f q
