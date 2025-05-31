#!/bin/bash
# setup-clojure-mcp.sh - Install and configure Clojure MCP server
# This script follows the "spilled coffee principle" - ensuring reproducible setup

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"
CLOJURE_MCP_DIR="$DOTFILES_DIR/mcp/clojure-mcp"
CONFIG_DIR="$HOME/.clojure-mcp"

echo -e "${GREEN}Setting up Clojure MCP server...${NC}"

# Check for required dependencies and install if possible
check_dependency() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${YELLOW}$1 is not installed. Attempting to install...${NC}"
    
    case "$1" in
      "git")
        echo -e "${RED}Error: git is required but not installed.${NC}"
        echo -e "Please install git first."
        exit 1
        ;;
      "java")
        if [ -f "$DOTFILES_DIR/utils/install-java.sh" ]; then
          echo -e "${YELLOW}Installing Java using the automated script...${NC}"
          bash "$DOTFILES_DIR/utils/install-java.sh"
          # Check if installation was successful
          if ! command -v java &> /dev/null; then
            echo -e "${RED}Error: Java installation failed.${NC}"
            exit 1
          fi
        else
          echo -e "${RED}Error: Java is required but not installed.${NC}"
          echo -e "Please install Java first."
          exit 1
        fi
        ;;
      "clojure")
        if [ -f "$DOTFILES_DIR/utils/install-clojure.sh" ]; then
          echo -e "${YELLOW}Installing Clojure using the automated script...${NC}"
          bash "$DOTFILES_DIR/utils/install-clojure.sh"
          # Check if installation was successful
          if ! command -v clojure &> /dev/null; then
            echo -e "${RED}Error: Clojure installation failed.${NC}"
            exit 1
          fi
        else
          echo -e "${RED}Error: Clojure is required but not installed.${NC}"
          echo -e "Please install Clojure first."
          exit 1
        fi
        ;;
      *)
        echo -e "${RED}Error: $1 is required but not installed.${NC}"
        echo -e "Please install $1 first."
        exit 1
        ;;
    esac
  fi
}

# Check for required dependencies
check_dependency "git"
check_dependency "java"
check_dependency "clojure"

# Clone or update the Clojure MCP repository
if [ -d "$CLOJURE_MCP_DIR/clojure-mcp" ]; then
  echo -e "${YELLOW}Updating existing Clojure MCP repository...${NC}"
  cd "$CLOJURE_MCP_DIR/clojure-mcp"
  git pull
else
  echo -e "${YELLOW}Cloning Clojure MCP repository...${NC}"
  mkdir -p "$CLOJURE_MCP_DIR"
  git clone https://github.com/bhauman/clojure-mcp.git "$CLOJURE_MCP_DIR/clojure-mcp"
fi

# Create configuration directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy configuration template if it doesn't exist
if [ ! -f "$CONFIG_DIR/config.edn" ]; then
  echo -e "${YELLOW}Creating default configuration...${NC}"
  
  # Check if the example config exists in the cloned repo
  if [ -f "$CLOJURE_MCP_DIR/clojure-mcp/config.example.edn" ]; then
    cp "$CLOJURE_MCP_DIR/clojure-mcp/config.example.edn" "$CONFIG_DIR/config.edn"
  else
    # Use our own example config if the repo doesn't have one
    cp "$CLOJURE_MCP_DIR/config.example.edn" "$CONFIG_DIR/config.edn"
  fi
  
  # Update the config with our customizations
  cat > "$CONFIG_DIR/config.edn" << EOF
{:port 7777
 :host "localhost"
 :project-dirs ["~/projects" "~/ppv"]
 :history-file "~/.clojure_mcp_history"
 :max-history-entries 1000}
EOF
fi

# Make the wrapper script executable
chmod +x "$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh"

echo -e "${GREEN}Clojure MCP setup complete!${NC}"
echo -e "To start using Clojure MCP:"
echo -e "1. Start the server: ${YELLOW}clj-mcp-start${NC}"
echo -e "2. In a new terminal, start a REPL session: ${YELLOW}clj-mcp${NC}"
echo -e "3. To create a new project: ${YELLOW}clj-mcp-new-project my-project${NC}"
echo -e "\nFor more information, see the README.md"
