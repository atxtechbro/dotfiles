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

# Amazon Q with trust setup - using improved FIFO approach to prevent hanging
# This function creates a named pipe to feed commands to Amazon Q while keeping the session interactive
# 
# How this works:
# 1. Create a temporary file with the trust commands
# 2. Create a named pipe (FIFO) for communication
# 3. Start a background process that feeds commands then user input
# 4. Launch Amazon Q reading from the FIFO
# 5. Clean up processes and files when done
qtrust() {
  echo "Setting up Amazon Q trust permissions..."
  
  # Create a temporary file for the commands
  TEMP_FILE=$(mktemp)
  echo "/tools trustall" > "$TEMP_FILE"
  echo "/tools untrust fs_write execute_bash use_aws" >> "$TEMP_FILE"
  
  # Create a named pipe (FIFO)
  FIFO=$(mktemp -u)
  mkfifo "$FIFO"
  
  # Start a background process that will feed commands then user input
  (cat "$TEMP_FILE"; cat) > "$FIFO" &
  BG_PID=$!
  
  # Launch Amazon Q reading from the FIFO
  q chat < "$FIFO"
  
  # Clean up
  kill $BG_PID 2>/dev/null || true
  rm "$TEMP_FILE" "$FIFO"
  
  # Log completion
  echo "Amazon Q session ended, trust setup complete."
}

# Export the function so it's available in subshells
export -f qtrust
