#!/bin/bash

# Enable debug mode to see all commands as they're executed
set -x

# =========================================================
# TEST HARNESS FOR GIT MCP SERVER
# =========================================================
# PURPOSE: Automated testing of Git MCP server functionality
# Converts manual test cases from test-git-mcp.md to automated tests
# =========================================================

# Source the common test harness
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/test-harness.sh"

# Test branch name
TEST_BRANCH="test-automation-branch"

# Function to run cleanup operations
cleanup() {
  echo -e "\n${BLUE}CLEANUP:${NC} Removing test branch if it exists"
  $TEST_MODEL chat --no-interactive --trust-all-tools "Delete the Git branch named $TEST_BRANCH if it exists" >/dev/null 2>&1
  echo "Cleanup complete"
}

# Run cleanup on script exit
trap cleanup EXIT

# Initialize test suite
init_test_suite "GIT MCP SERVER" "Git"

# Basic Git Operations

# Test: Check Git Status
run_test "Check Git Status" \
         "Check the status of the current Git repository" \
         "(branch|modified|untracked|staged|clean|working)"

# Test: List Branches
run_test "List Branches" \
         "List all branches in the current Git repository" \
         "(branch|main|master|HEAD)"

# Test: View Commit History
run_test "View Commit History" \
         "Show the commit history of the current Git repository" \
         "(commit|author|date)"

# Advanced Git Operations

# Test: Create a Branch
run_test "Create a Branch" \
         "Create a new Git branch named $TEST_BRANCH" \
         "(branch|created|success|$TEST_BRANCH)"

# Test: Switch Branches
run_test "Switch Branches" \
         "Switch to the $TEST_BRANCH branch" \
         "(switched|checkout|$TEST_BRANCH)"

# Test: Make Changes and Commit
skip_test "Make Changes and Commit" \
         "This test requires file creation which is complex to automate and verify"

# Print summary
print_summary

# Exit with appropriate status code
if [ $FAILED -gt 0 ]; then
  exit 1
else
  exit 0
fi
