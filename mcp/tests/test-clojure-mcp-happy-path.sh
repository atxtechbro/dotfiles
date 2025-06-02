#!/bin/bash

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

# Custom run_test function that shows more output and checks for tool usage
custom_run_test() {
  local test_name="$1"
  local command="$2"
  local expected_pattern="$3"
  local tool_pattern="$4"
  
  echo -e "\n${BLUE}TEST:${NC} $test_name"
  echo "Command: $command"
  TOTAL=$((TOTAL+1))
  
  # Run the command through the specified model CLI
  echo "Running test through $TEST_MODEL CLI..."
  
  case "$TEST_MODEL" in
    q)
      # Use trust-all-tools to avoid interactive prompts
      echo "Executing: $TEST_MODEL chat --no-interactive --trust-all-tools \"$command\""
      full_result=$($TEST_MODEL chat --no-interactive --trust-all-tools "$command" 2>/dev/null)
      ;;
    claude)
      # Assuming claude CLI has similar interface
      echo "Executing: $TEST_MODEL chat --no-interactive --trust-all-tools \"$command\""
      full_result=$($TEST_MODEL chat --no-interactive --trust-all-tools "$command" 2>/dev/null)
      ;;
    *)
      echo -e "${RED}Error: Unknown model $TEST_MODEL${NC}"
      FAILED=$((FAILED+1))
      return 1
      ;;
  esac
  
  # Show a portion of the response
  echo -e "\n${YELLOW}Response excerpt (first 500 chars):${NC}"
  echo "${full_result:0:500}"
  echo -e "${YELLOW}...[truncated]...${NC}"
  
  # Check if the result contains the expected pattern
  if echo "$full_result" | grep -q -E "$expected_pattern"; then
    echo -e "${GREEN}✓ PASSED${NC}: Output contains expected result pattern: '$expected_pattern'"
  else
    echo -e "${RED}✗ FAILED${NC}: Expected result pattern not found"
    echo "Expected result pattern: $expected_pattern"
    FAILED=$((FAILED+1))
    echo "----------------------------------------"
    return 1
  fi
  
  # Check if the result contains the tool usage pattern
  if echo "$full_result" | grep -q -E "$tool_pattern"; then
    echo -e "${GREEN}✓ PASSED${NC}: Output contains tool usage pattern: '$tool_pattern'"
    PASSED=$((PASSED+1))
  else
    echo -e "${RED}✗ FAILED${NC}: Tool usage pattern not found"
    echo "Expected tool usage pattern: $tool_pattern"
    FAILED=$((FAILED+1))
  fi
  echo "----------------------------------------"
}

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

# Test: Basic Clojure Evaluation
custom_run_test "Basic Clojure Evaluation" \
         "Please use clojure_eval tool to evaluate and calculate (+ 2 2) in Clojure" \
         "(4|four)" \
         "(Using tool: clojure_eval|🛠️.*clojure_eval|clojure_mcp)"

# Wait between tests
sleep 5

# Test: Clojure Function Definition and Evaluation
custom_run_test "Clojure Function Definition and Evaluation" \
         "Use the clojure_eval tool to define a function named add-two that adds 2 to its argument in Clojure, then evaluate (add-two 3)" \
         "(5|five)" \
         "(Using tool: clojure_eval|🛠️.*clojure_eval|clojure_mcp)"

# Wait between tests
sleep 5

# Test: Read deps.edn File with Clojure MCP
custom_run_test "Read deps.edn File with Clojure MCP" \
         "Use clojure_eval or another Clojure MCP tool to read and analyze the deps.edn file in the current directory" \
         "(nREPL|MCP|server|clojure-mcp)" \
         "(Using tool: clojure_eval|🛠️.*clojure_eval|clojure_mcp)"

# Print summary
print_summary

# Exit with appropriate status code
if [ $FAILED -gt 0 ]; then
  exit 1
else
  exit 0
fi
