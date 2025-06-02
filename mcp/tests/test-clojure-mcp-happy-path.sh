#!/bin/bash

# Enable debug mode to see all commands as they're executed
set -x

# =========================================================
# TEST HARNESS FOR CLOJURE MCP SERVER - HAPPY PATH
# =========================================================
# PURPOSE: Automated testing of Clojure MCP server functionality
# Tests the basic functionality when launched from dotfiles repository
# =========================================================

# Source the common test harness
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/test-harness.sh"

# Define test directory
DOTFILES_DIR="/home/linuxmint-lp/ppv/pillars/dotfiles"

# Initialize test suite
init_test_suite "CLOJURE MCP SERVER - HAPPY PATH" "Clojure"

# Give extra time for MCP servers to fully load
echo -e "${YELLOW}Giving extra time for MCP servers to fully initialize...${NC}"
sleep 15

# Basic Clojure evaluation test from dotfiles directory
echo -e "\n${BLUE}SECTION:${NC} Testing Clojure MCP from dotfiles directory"

# Test from dotfiles directory (should always work)
cd "$DOTFILES_DIR"
echo -e "${YELLOW}Testing from dotfiles directory...${NC}"
sleep 3

# Test: Clojure Tool Usage and Evaluation
run_test "Clojure Tool Usage and Evaluation" \
         "Evaluate (+ 2 2) using Clojure" \
         "(Using tool: clojure_eval|🛠️.*clojure_eval)"

# Wait between tests
sleep 5

# Test: Clojure Function Definition with Tool Usage
run_test "Clojure Function Definition with Tool Usage" \
         "Define a function named add-two that adds 2 to its argument in Clojure and evaluate it with input 3" \
         "(Using tool: clojure_eval|🛠️.*clojure_eval)"

# Print summary
print_summary

# Exit with appropriate status code
if [ $FAILED -gt 0 ]; then
  exit 1
else
  exit 0
fi
