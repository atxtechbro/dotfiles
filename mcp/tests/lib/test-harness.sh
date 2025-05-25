#!/bin/bash

# =========================================================
# MCP SERVER TEST HARNESS
# =========================================================
# PURPOSE: Common functions for MCP server testing
# This library provides reusable functions for all MCP server tests
# =========================================================

# Colors for output
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Test counter
export TOTAL=0
export PASSED=0
export FAILED=0
export SKIPPED=0

# Default model to use for testing
export TEST_MODEL=${TEST_MODEL:-"q"}

# Default timeout for commands (in milliseconds)
export TEST_TIMEOUT=${TEST_TIMEOUT:-30000}

# Function to run a test
run_test() {
  local test_name="$1"
  local command="$2"
  local expected_pattern="$3"
  
  echo -e "\n${BLUE}TEST:${NC} $test_name"
  echo "Command: $command"
  TOTAL=$((TOTAL+1))
  
  # Run the command through the specified model CLI
  echo "Running test through $TEST_MODEL CLI..."
  
  case "$TEST_MODEL" in
    q)
      # Use trust-all-tools to avoid interactive prompts
      full_result=$($TEST_MODEL chat --no-interactive --trust-all-tools "$command" 2>/dev/null)
      ;;
    claude)
      # Assuming claude CLI has similar interface
      full_result=$($TEST_MODEL chat --no-interactive --trust-all-tools "$command" 2>/dev/null)
      ;;
    *)
      echo -e "${RED}Error: Unknown model $TEST_MODEL${NC}"
      FAILED=$((FAILED+1))
      return 1
      ;;
  esac
  
  # Check if the result contains the expected pattern
  # Search through the entire output, regardless of initialization messages
  if echo "$full_result" | grep -q -E "$expected_pattern"; then
    echo -e "${GREEN}✓ PASSED${NC}: Output contains expected pattern"
    PASSED=$((PASSED+1))
  else
    echo -e "${RED}✗ FAILED${NC}: Expected pattern not found"
    echo "Expected pattern: $expected_pattern"
    echo "Result excerpt (first 500 chars):"
    echo "${full_result:0:500}"
    FAILED=$((FAILED+1))
    
    # Exit immediately on first failure if EXIT_ON_FIRST_FAILURE is set
    if [[ "$EXIT_ON_FIRST_FAILURE" == "true" ]]; then
      echo -e "${RED}Exiting on first failure as requested${NC}"
      print_summary
      exit 1
    fi
  fi
  echo "----------------------------------------"
}

# Function to skip a test
skip_test() {
  local test_name="$1"
  local reason="$2"
  
  echo -e "\n${BLUE}TEST:${NC} $test_name"
  echo -e "${YELLOW}⚠ SKIPPED${NC}: $reason"
  SKIPPED=$((SKIPPED+1))
  TOTAL=$((TOTAL+1))
  echo "----------------------------------------"
}

# Function to print test summary
print_summary() {
  echo "=========================================="
  echo "SUMMARY: $PASSED/$TOTAL tests passed"
  if [ $FAILED -gt 0 ]; then
    echo -e "${RED}$FAILED tests failed${NC}"
  fi
  if [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}$SKIPPED tests skipped${NC}"
  fi
  echo "=========================================="
}

# Function to initialize test suite
init_test_suite() {
  local suite_name="$1"
  local server_name="$2"
  
  echo "=========================================="
  echo "RUNNING $suite_name TESTS"
  echo "=========================================="
  echo "Date: $(date)"
  echo "Working directory: $(pwd)"
  echo "Model: $TEST_MODEL"
  echo "=========================================="
  
  # Give servers time to load
  echo -e "${YELLOW}Waiting for MCP servers to load...${NC}"
  sleep 5
}

# Export functions
export -f run_test
export -f skip_test
export -f print_summary
export -f init_test_suite
