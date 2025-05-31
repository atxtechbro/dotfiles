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
CONFIG_DIR="$HOME/.clojure"

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

# Create configuration directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Create or update deps.edn with clojure-mcp configuration
DEPS_FILE="$CONFIG_DIR/deps.edn"

# Get the latest commit SHA from the clojure-mcp repository
echo -e "${YELLOW}Fetching latest commit SHA from clojure-mcp repository...${NC}"
LATEST_SHA=$(curl -s https://api.github.com/repos/bhauman/clojure-mcp/commits/main | grep -o '"sha": "[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$LATEST_SHA" ]; then
  echo -e "${RED}Error: Could not fetch latest commit SHA.${NC}"
  echo -e "Using placeholder SHA. Please update manually."
  LATEST_SHA="83627e7095f0ebab3d5503a5b2ee94aa6953cb0d"
fi

# Check if deps.edn exists
if [ -f "$DEPS_FILE" ]; then
  # Check if the file already contains clojure-mcp configuration
  if grep -q "clojure-mcp" "$DEPS_FILE"; then
    echo -e "${YELLOW}Updating existing clojure-mcp configuration in $DEPS_FILE...${NC}"
    # Create a temporary file for the updated content
    TMP_FILE=$(mktemp)
    
    # Update the SHA in the existing configuration
    sed "s/\"git\/sha\" \"[^\"]*\"/\"git\/sha\" \"$LATEST_SHA\"/" "$DEPS_FILE" > "$TMP_FILE"
    
    # Replace the original file with the updated content
    mv "$TMP_FILE" "$DEPS_FILE"
  else
    echo -e "${YELLOW}Adding clojure-mcp configuration to existing $DEPS_FILE...${NC}"
    # Create a temporary file for the updated content
    TMP_FILE=$(mktemp)
    
    # Extract the content before the closing brace
    sed -e '$ d' "$DEPS_FILE" > "$TMP_FILE"
    
    # Add the clojure-mcp configuration
    cat >> "$TMP_FILE" << EOF
 :aliases 
  {:mcp 
    {:deps {org.slf4j/slf4j-nop {:mvn/version "2.0.16"}
            com.bhauman/clojure-mcp {:git/url "https://github.com/bhauman/clojure-mcp.git"
                                     :git/sha "$LATEST_SHA"}}
     :exec-fn clojure-mcp.main/start-mcp-server
     :exec-args {:port 7888}}}}
EOF
    
    # Replace the original file with the updated content
    mv "$TMP_FILE" "$DEPS_FILE"
  fi
else
  echo -e "${YELLOW}Creating new $DEPS_FILE with clojure-mcp configuration...${NC}"
  # Create a new deps.edn file with the clojure-mcp configuration
  cat > "$DEPS_FILE" << EOF
{:paths ["src"]
 :deps {}
 :aliases 
  {:mcp 
    {:deps {org.slf4j/slf4j-nop {:mvn/version "2.0.16"}
            com.bhauman/clojure-mcp {:git/url "https://github.com/bhauman/clojure-mcp.git"
                                     :git/sha "$LATEST_SHA"}}
     :exec-fn clojure-mcp.main/start-mcp-server
     :exec-args {:port 7888}}}}
EOF
fi

# Create a wrapper script for starting the Clojure MCP server
WRAPPER_SCRIPT="$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh"

cat > "$WRAPPER_SCRIPT" << EOF
#!/bin/bash
# clojure-mcp-wrapper.sh - Wrapper script for Clojure MCP server
# This script follows the pattern of other MCP wrapper scripts in the repository

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if the server is already running
if pgrep -f "clojure.*:mcp" > /dev/null; then
  echo -e "\${YELLOW}Clojure MCP server is already running${NC}"
  exit 0
fi

# Check for required dependencies
if ! command -v clojure &> /dev/null; then
  echo -e "\${RED}Error: clojure is required but not installed.${NC}"
  echo -e "Please install clojure first."
  exit 1
fi

# Start the server
echo -e "\${GREEN}Starting Clojure MCP server...${NC}"
exec clojure -X:mcp
EOF

# Make the wrapper script executable
chmod +x "$WRAPPER_SCRIPT"

# Create a sample project.clj template for new projects
mkdir -p "$CLOJURE_MCP_DIR/templates"
cat > "$CLOJURE_MCP_DIR/templates/project.clj" << EOF
(defproject {{project-name}} "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.11.1"]]
  :repl-options {:init-ns {{project-name}}.core}
  :aliases {"nrepl" {:extra-paths ["test"]
                     :extra-deps {nrepl/nrepl {:mvn/version "1.3.1"}}
                     :jvm-opts ["-Djdk.attach.allowAttachSelf"]
                     :main-opts ["-m" "nrepl.cmdline" "--port" "7888"]}})
EOF

# Create a sample deps.edn template for new projects
cat > "$CLOJURE_MCP_DIR/templates/deps.edn" << EOF
{:paths ["src"]
 :deps {org.clojure/clojure {:mvn/version "1.11.1"}}
 :aliases {
   ;; nREPL server for AI to connect to
   :nrepl {:extra-paths ["test"] 
           :extra-deps {nrepl/nrepl {:mvn/version "1.3.1"}}
           :jvm-opts ["-Djdk.attach.allowAttachSelf"]
           :main-opts ["-m" "nrepl.cmdline" "--port" "7888"]}}}
EOF

# Create a README.md file with usage instructions
cat > "$CLOJURE_MCP_DIR/README.md" << EOF
# Clojure MCP Integration

This directory contains the configuration and scripts for integrating Clojure with the Model Context Protocol (MCP).

## Usage

### Starting the Clojure MCP Server

To start the Clojure MCP server:

\`\`\`bash
clj-mcp-start
\`\`\`

### Starting a REPL Session

In a new terminal, start a REPL session:

\`\`\`bash
cd /path/to/your/project
clojure -M:nrepl
\`\`\`

### Creating a New Project

To create a new Clojure project with MCP integration:

\`\`\`bash
clj-mcp-new-project my-project
cd my-project
clojure -M:nrepl
\`\`\`

### Saving and Loading REPL Sessions

To save the current session:

\`\`\`bash
clj-mcp-save-session my-session.edn
\`\`\`

To load a previous session:

\`\`\`bash
clj-mcp-load-session my-session.edn
\`\`\`

### Generating a Project Summary

To generate a project summary based on your REPL history:

\`\`\`bash
clj-mcp-summarize
\`\`\`

## Configuration

The Clojure MCP server is configured in \`~/.clojure/deps.edn\`.

## Troubleshooting

If you encounter issues:

1. Check that the nREPL server is running on port 7888
2. Verify that the Clojure MCP server is running
3. Check for error messages in the terminal where the server is running
EOF

# Create a script for creating new Clojure projects with MCP integration
cat > "$DOTFILES_DIR/bin/clj-mcp-new-project" << EOF
#!/bin/bash
# clj-mcp-new-project - Create a new Clojure project with MCP integration

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if a project name was provided
if [ -z "\$1" ]; then
  echo -e "\${RED}Error: No project name provided.${NC}"
  echo -e "Usage: clj-mcp-new-project <project-name>"
  exit 1
fi

PROJECT_NAME="\$1"
DOTFILES_DIR="\$HOME/ppv/pillars/dotfiles"
TEMPLATES_DIR="\$DOTFILES_DIR/mcp/clojure-mcp/templates"

# Create the project directory
mkdir -p "\$PROJECT_NAME/src/\${PROJECT_NAME//-/_}/core"
mkdir -p "\$PROJECT_NAME/test/\${PROJECT_NAME//-/_}/core"

# Create the deps.edn file
sed "s/{{project-name}}/\${PROJECT_NAME//-/_}/g" "\$TEMPLATES_DIR/deps.edn" > "\$PROJECT_NAME/deps.edn"

# Create a basic core.clj file
cat > "\$PROJECT_NAME/src/\${PROJECT_NAME//-/_}/core.clj" << EOL
(ns \${PROJECT_NAME//-/_}.core)

(defn foo
  "I don't do a whole lot."
  [x]
  (println x "Hello, World!"))
EOL

# Create a basic test file
cat > "\$PROJECT_NAME/test/\${PROJECT_NAME//-/_}/core_test.clj" << EOL
(ns \${PROJECT_NAME//-/_}.core-test
  (:require [clojure.test :refer :all]
            [\${PROJECT_NAME//-/_}.core :refer :all]))

(deftest a-test
  (testing "FIXME, I fail."
    (is (= 0 1))))
EOL

echo -e "\${GREEN}Created new Clojure project: \$PROJECT_NAME${NC}"
echo -e "To start using it:"
echo -e "1. cd \$PROJECT_NAME"
echo -e "2. Start the nREPL server: ${YELLOW}clojure -M:nrepl${NC}"
echo -e "3. In another terminal, start the Clojure MCP server: ${YELLOW}clj-mcp-start${NC}"
EOF

# Make the script executable
mkdir -p "$DOTFILES_DIR/bin"
chmod +x "$DOTFILES_DIR/bin/clj-mcp-new-project"

# Create a script for starting the Clojure MCP server
cat > "$DOTFILES_DIR/bin/clj-mcp-start" << EOF
#!/bin/bash
# clj-mcp-start - Start the Clojure MCP server

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if the server is already running
if pgrep -f "clojure.*:mcp" > /dev/null; then
  echo -e "\${YELLOW}Clojure MCP server is already running${NC}"
  exit 0
fi

# Start the server
echo -e "\${GREEN}Starting Clojure MCP server...${NC}"
exec clojure -X:mcp
EOF

# Make the script executable
chmod +x "$DOTFILES_DIR/bin/clj-mcp-start"

# Create a script for saving REPL sessions
cat > "$DOTFILES_DIR/bin/clj-mcp-save-session" << EOF
#!/bin/bash
# clj-mcp-save-session - Save the current REPL session

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if a session name was provided
if [ -z "\$1" ]; then
  echo -e "\${RED}Error: No session name provided.${NC}"
  echo -e "Usage: clj-mcp-save-session <session-name.edn>"
  exit 1
fi

SESSION_NAME="\$1"

# TODO: Implement session saving logic
# This is a placeholder for future implementation

echo -e "\${GREEN}Session saved to \$SESSION_NAME${NC}"
EOF

# Make the script executable
chmod +x "$DOTFILES_DIR/bin/clj-mcp-save-session"

# Create a script for loading REPL sessions
cat > "$DOTFILES_DIR/bin/clj-mcp-load-session" << EOF
#!/bin/bash
# clj-mcp-load-session - Load a saved REPL session

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if a session name was provided
if [ -z "\$1" ]; then
  echo -e "\${RED}Error: No session name provided.${NC}"
  echo -e "Usage: clj-mcp-load-session <session-name.edn>"
  exit 1
fi

SESSION_NAME="\$1"

# Check if the session file exists
if [ ! -f "\$SESSION_NAME" ]; then
  echo -e "\${RED}Error: Session file \$SESSION_NAME does not exist.${NC}"
  exit 1
fi

# TODO: Implement session loading logic
# This is a placeholder for future implementation

echo -e "\${GREEN}Session loaded from \$SESSION_NAME${NC}"
EOF

# Make the script executable
chmod +x "$DOTFILES_DIR/bin/clj-mcp-load-session"

# Create a script for generating project summaries
cat > "$DOTFILES_DIR/bin/clj-mcp-summarize" << EOF
#!/bin/bash
# clj-mcp-summarize - Generate a project summary based on REPL history

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# TODO: Implement project summary generation logic
# This is a placeholder for future implementation

echo -e "\${GREEN}Project summary generated.${NC}"
EOF

# Make the script executable
chmod +x "$DOTFILES_DIR/bin/clj-mcp-summarize"

# Update the mcp.json file to include the Clojure MCP server
MCP_JSON="$DOTFILES_DIR/mcp/mcp.json"

if [ -f "$MCP_JSON" ]; then
  # Check if the file already contains clojure-mcp configuration
  if grep -q "clojure-mcp" "$MCP_JSON"; then
    echo -e "${YELLOW}Clojure MCP already configured in $MCP_JSON...${NC}"
  else
    echo -e "${YELLOW}Adding Clojure MCP configuration to $MCP_JSON...${NC}"
    # Create a temporary file for the updated content
    TMP_FILE=$(mktemp)
    
    # Extract the content before the closing brace
    sed -e '$ d' "$MCP_JSON" > "$TMP_FILE"
    
    # Add the clojure-mcp configuration
    cat >> "$TMP_FILE" << EOF
,
  "clojure-mcp": {
    "command": "/bin/bash",
    "args": [
      "-c",
      "$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh"
    ]
  }
}
EOF
    
    # Replace the original file with the updated content
    mv "$TMP_FILE" "$MCP_JSON"
  fi
else
  echo -e "${YELLOW}Creating new $MCP_JSON with Clojure MCP configuration...${NC}"
  # Create a new mcp.json file with the clojure-mcp configuration
  cat > "$MCP_JSON" << EOF
{
  "clojure-mcp": {
    "command": "/bin/bash",
    "args": [
      "-c",
      "$DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh"
    ]
  }
}
EOF
fi

echo -e "${GREEN}Clojure MCP setup complete!${NC}"
echo -e "To start using Clojure MCP:"
echo -e "1. Start the server: ${YELLOW}clj-mcp-start${NC}"
echo -e "2. In a new terminal, start a REPL session: ${YELLOW}clojure -M:nrepl${NC}"
echo -e "3. To create a new project: ${YELLOW}clj-mcp-new-project my-project${NC}"
echo -e "\nFor more information, see the README.md in $CLOJURE_MCP_DIR"
