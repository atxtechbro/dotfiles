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

# Amazon Q with trust setup - using FIFO (named pipe) approach
# This function creates a named pipe to feed commands to Amazon Q while keeping the session interactive
# 
# How FIFO works:
# 1. A named pipe (FIFO) is a special file that acts as a pipe between processes
# 2. One process writes to the FIFO, another reads from it
# 3. Unlike regular files, data written to a FIFO is consumed when read
# 4. This allows for interprocess communication while maintaining an interactive session
#
# The automation flow:
# - Create a named pipe (FIFO) using mkfifo
# - Start a background process that writes trust commands to the FIFO
# - Then redirect stdin to the FIFO so user can continue interacting
# - Launch Amazon Q reading from the FIFO
# - When Amazon Q exits, clean up the FIFO
qtrust() {
  echo "Setting up Amazon Q trust permissions..."
  
  # Create a named pipe (FIFO)
  FIFO=$(mktemp -u)
  mkfifo "$FIFO"
  
  # Start a background process that will write to the FIFO
  (
    # Write the trust commands
    echo "/tools trustall"
    echo "/tools untrust fs_write execute_bash use_aws"
    
    # Keep the pipe open for user input
    cat > "$FIFO"
  ) > "$FIFO" &
  
  # Launch Amazon Q reading from the FIFO
  q chat < "$FIFO"
  
  # Clean up
  rm "$FIFO"
}

# Export the function so it's available in subshells
export -f qtrust
