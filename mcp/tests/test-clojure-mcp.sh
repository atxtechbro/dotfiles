#!/bin/bash

# Enable debug mode to see all commands as they're executed
set -x

# =========================================================
# TEST HARNESS FOR CLOJURE MCP SERVER
# =========================================================
# PURPOSE: Automated testing of Clojure MCP server functionality
# Tests the ability to use Clojure MCP from different directories
# =========================================================

# Source the common test harness
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/test-harness.sh"

# Define test directories
# These directories represent different locations to test from
DOTFILES_DIR="/home/linuxmint-lp/ppv/pillars/dotfiles"
PILLARS_DIR="/home/linuxmint-lp/ppv/pillars"
PIPELINES_DIR="/home/linuxmint-lp/ppv/pipelines"
HOME_DIR="/home/linuxmint-lp"
TMP_DIR="/tmp"
RANDOM_DIR="/tmp/random-dir-$$"

# Create random directory if it doesn't exist
mkdir -p "$RANDOM_DIR"

# Function to run cleanup operations
cleanup() {
  echo -e "\n${BLUE}CLEANUP:${NC} Removing temporary directories"
  [ -d "$RANDOM_DIR" ] && rm -rf "$RANDOM_DIR"
  echo "Cleanup complete"
}

# Run cleanup on script exit
trap cleanup EXIT

# Initialize test suite
init_test_suite "CLOJURE MCP SERVER" "Clojure"

# Basic Clojure evaluation test from different directories
echo -e "\n${BLUE}SECTION:${NC} Testing Clojure MCP from different directories"

# Test from dotfiles directory (should always work)
cd "$DOTFILES_DIR"
run_test "Evaluate Clojure from dotfiles directory" \
         "Using Clojure, what is the result of (+ 2 2)?" \
         "(4|four)"

# Test from pillars directory (should work with our changes)
cd "$PILLARS_DIR"
run_test "Evaluate Clojure from pillars directory" \
         "Using Clojure, what is the result of (+ 2 2)?" \
         "(4|four)"

# Test from pipelines directory (should work with our changes)
cd "$PIPELINES_DIR"
run_test "Evaluate Clojure from pipelines directory" \
         "Using Clojure, what is the result of (+ 2 2)?" \
         "(4|four)"

# Test from home directory (may or may not work)
cd "$HOME_DIR"
run_test "Evaluate Clojure from home directory" \
         "Using Clojure, what is the result of (+ 2 2)?" \
         "(4|four)"

# Test from /tmp directory (may or may not work)
cd "$TMP_DIR"
run_test "Evaluate Clojure from /tmp directory" \
         "Using Clojure, what is the result of (+ 2 2)?" \
         "(4|four)"

# Test from random directory (may or may not work)
cd "$RANDOM_DIR"
run_test "Evaluate Clojure from random directory" \
         "Using Clojure, what is the result of (+ 2 2)?" \
         "(4|four)"

# Test file access from different directories
echo -e "\n${BLUE}SECTION:${NC} Testing Clojure MCP file access from different directories"

# Create a test file in the random directory
TEST_FILE="$RANDOM_DIR/test-file.clj"
echo '(defn add-two [x] (+ x 2))' > "$TEST_FILE"

# Test reading a file from random directory
cd "$RANDOM_DIR"
run_test "Read file from current directory" \
         "Read the file test-file.clj in the current directory and explain what it does" \
         "(add-two|function|adds 2)"

# Test reading a file from dotfiles when in a different directory
cd "$TMP_DIR"
run_test "Read file from dotfiles while in /tmp" \
         "Read the file deps.edn in the dotfiles directory and explain what it contains" \
         "(nREPL|MCP|server|clojure-mcp)"

# Print summary
print_summary

# Exit with appropriate status code
if [ $FAILED -gt 0 ]; then
  exit 1
else
  exit 0
fi
