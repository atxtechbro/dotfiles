#!/bin/bash
# clojure-mcp.sh - Aliases and functions for Clojure MCP integration
# This file is automatically loaded by .bashrc through the modular configuration system

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"
CLOJURE_MCP_DIR="$DOTFILES_DIR/mcp/clojure-mcp"
CONFIG_DIR="$HOME/.clojure-mcp"

# Start Clojure MCP server
alias clj-mcp-start="$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh"

# Function to detect available MCP clients and use the preferred one
clj-mcp() {
  local preferred_client=${CLJ_MCP_CLIENT:-"auto"}
  local client_cmd=""
  
  # Auto-detect available clients if not specified
  if [ "$preferred_client" = "auto" ]; then
    if command -v q &> /dev/null; then
      client_cmd="q"
    elif command -v claude &> /dev/null; then
      client_cmd="claude"
    elif command -v gh &> /dev/null && gh copilot --help &> /dev/null; then
      client_cmd="gh copilot"
    else
      echo "No supported MCP client found. Please install Amazon Q, Claude, or GitHub Copilot CLI."
      return 1
    fi
  else
    # Use the specified client
    case "$preferred_client" in
      "q") client_cmd="q" ;;
      "claude") client_cmd="claude" ;;
      "copilot") client_cmd="gh copilot" ;;
      *) echo "Unsupported MCP client: $preferred_client"; return 1 ;;
    esac
  fi
  
  # Ensure the MCP server is registered with the client
  if [ "$client_cmd" = "q" ]; then
    q mcp list | grep -q "clojure-mcp" || q mcp add clojure-mcp http://localhost:7777
  fi
  
  # Start a REPL session with the chosen client
  if [ -z "$1" ]; then
    echo "Starting Clojure REPL with $client_cmd..."
    case "$client_cmd" in
      "q") q chat ;;
      "claude") claude chat ;;
      "gh copilot") gh copilot suggest ;;
    esac
  else
    # If a file is provided, load it into the REPL
    echo "Loading $1 into Clojure REPL with $client_cmd..."
    case "$client_cmd" in
      "q") cat "$1" | q chat ;;
      "claude") cat "$1" | claude chat ;;
      "gh copilot") cat "$1" | gh copilot suggest ;;
    esac
  fi
}

# Function to create a new Clojure project with MCP integration
clj-mcp-new-project() {
  if [ -z "$1" ]; then
    echo "Usage: clj-mcp-new-project <project-name>"
    return 1
  fi
  
  local project_name="$1"
  
  # Create project using deps-new
  clojure -Sdeps '{:deps {io.github.seancorfield/deps-new {:mvn/version "RELEASE"}}}' \
          -m deps-new.create \
          io.github.seancorfield/clj-template "$project_name"
  
  cd "$project_name"
  
  # Add MCP configuration to the project
  mkdir -p .clojure-mcp
  cat > .clojure-mcp/config.edn << EOL
{:project-name "$project_name"
 :history-file ".clojure-mcp/history.edn"
 :max-history-entries 1000}
EOL

  echo "Created new Clojure project '$project_name' with MCP integration"
  echo "To start a REPL session, run: cd $project_name && clj-mcp"
}

# Function to save REPL session to history file
clj-mcp-save-session() {
  local session_file="${1:-$(date +%Y%m%d_%H%M%S)_clj_session.edn}"
  
  if [ -f "$CONFIG_DIR/history.edn" ]; then
    cp "$CONFIG_DIR/history.edn" "$session_file"
    echo "Session saved to $session_file"
  else
    echo "No session history found"
  fi
}

# Function to load a previous REPL session
clj-mcp-load-session() {
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Usage: clj-mcp-load-session <session-file>"
    return 1
  fi
  
  cp "$1" "$CONFIG_DIR/history.edn"
  echo "Session loaded from $1"
}

# Function to generate a project summary based on REPL history
clj-mcp-summarize() {
  local project_dir="${1:-.}"
  local output_file="${2:-$project_dir/PROJECT_SUMMARY.md}"
  
  if [ ! -d "$project_dir" ]; then
    echo "Error: Project directory not found: $project_dir"
    return 1
  fi
  
  # Check if we have a history file
  local history_file="$project_dir/.clojure-mcp/history.edn"
  if [ ! -f "$history_file" ] && [ -f "$CONFIG_DIR/history.edn" ]; then
    history_file="$CONFIG_DIR/history.edn"
  fi
  
  if [ ! -f "$history_file" ]; then
    echo "No REPL history found for this project"
    return 1
  fi
  
  echo "Generating project summary based on REPL history..."
  
  # Use the detected MCP client to generate a summary
  local preferred_client=${CLJ_MCP_CLIENT:-"auto"}
  local client_cmd=""
  
  # Auto-detect available clients
  if [ "$preferred_client" = "auto" ]; then
    if command -v q &> /dev/null; then
      client_cmd="q"
    elif command -v claude &> /dev/null; then
      client_cmd="claude"
    elif command -v gh &> /dev/null && gh copilot --help &> /dev/null; then
      client_cmd="gh copilot"
    else
      echo "No supported MCP client found. Please install Amazon Q, Claude, or GitHub Copilot CLI."
      return 1
    fi
  else
    # Use the specified client
    case "$preferred_client" in
      "q") client_cmd="q" ;;
      "claude") client_cmd="claude" ;;
      "copilot") client_cmd="gh copilot" ;;
      *) echo "Unsupported MCP client: $preferred_client"; return 1 ;;
    esac
  fi
  
  # Create a prompt for the AI to generate a summary
  local prompt="Based on my Clojure REPL history and project files, please generate a comprehensive project summary markdown document. Include:
1. Project overview and purpose
2. Key components and their relationships
3. Important functions and their usage
4. Development decisions and their rationale
5. Current status and next steps

This summary should help new developers understand the project quickly and serve as documentation of our development process."
  
  # Use the client to generate the summary
  case "$client_cmd" in
    "q")
      echo "$prompt" | q chat > "$output_file"
      ;;
    "claude")
      echo "$prompt" | claude chat > "$output_file"
      ;;
    "gh copilot")
      echo "$prompt" | gh copilot suggest > "$output_file"
      ;;
  esac
  
  echo "Project summary generated: $output_file"
}

# Add Clojure MCP server to Amazon Q if available
if command -v q &> /dev/null; then
  q mcp list 2>/dev/null | grep -q "clojure-mcp" || q mcp add clojure-mcp http://localhost:7777 2>/dev/null
fi