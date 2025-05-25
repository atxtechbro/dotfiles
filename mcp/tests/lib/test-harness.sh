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
      result=$($TEST_MODEL chat --no-interactive "$command" 2>/dev/null)
      ;;
    claude)
      # Assuming claude CLI has similar interface
      result=$($TEST_MODEL chat --no-interactive "$command" 2>/dev/null)
      ;;
    *)
      echo -e "${RED}Error: Unknown model $TEST_MODEL${NC}"
      FAILED=$((FAILED+1))
      return 1
      ;;
  esac
  
  # Check if the result contains the expected pattern
  if echo "$result" | grep -q -E "$expected_pattern"; then
    echo -e "${GREEN}✓ PASSED${NC}: Output contains expected pattern"
    PASSED=$((PASSED+1))
  else
    echo -e "${RED}✗ FAILED${NC}: Expected pattern not found"
    echo "Expected pattern: $expected_pattern"
    echo "Result excerpt: ${result:0:200}..."
    FAILED=$((FAILED+1))
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
  
  echo "=========================================="
  echo "RUNNING $suite_name TESTS"
  echo "=========================================="
  echo "Date: $(date)"
  echo "Working directory: $(pwd)"
  echo "Model: $TEST_MODEL"
  echo "=========================================="
}

# Export functions
export -f run_test
export -f skip_test
export -f print_summary
export -f init_test_suite
