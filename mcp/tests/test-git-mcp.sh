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
# Test worktree paths
TEST_WORKTREE_PATH="/tmp/test-worktree-$$"
TEST_WORKTREE_NEW_PATH="/tmp/test-worktree-new-$$"

# Function to run cleanup operations
cleanup() {
  echo -e "\n${BLUE}CLEANUP:${NC} Removing test branch if it exists"
  $TEST_MODEL chat --no-interactive --trust-all-tools "Delete the Git branch named $TEST_BRANCH if it exists" >/dev/null 2>&1
  
  echo -e "\n${BLUE}CLEANUP:${NC} Removing test worktrees if they exist"
  $TEST_MODEL chat --no-interactive --trust-all-tools "Remove the Git worktree at $TEST_WORKTREE_PATH if it exists" >/dev/null 2>&1
  $TEST_MODEL chat --no-interactive --trust-all-tools "Remove the Git worktree at $TEST_WORKTREE_NEW_PATH if it exists" >/dev/null 2>&1
  
  # Clean up the directories if they still exist
  [ -d "$TEST_WORKTREE_PATH" ] && rm -rf "$TEST_WORKTREE_PATH"
  [ -d "$TEST_WORKTREE_NEW_PATH" ] && rm -rf "$TEST_WORKTREE_NEW_PATH"
  
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

# Git Worktree Operations
# Added based on https://github.com/cyanheads/git-mcp-server/issues/11#issuecomment-2908405217
# Reference: Issue #293 by atxtechbro

echo -e "\n${BLUE}SECTION:${NC} Git Worktree Operations"

# Test: List Worktrees
run_test "List Worktrees" \
         "List all Git worktrees in the current repository" \
         "(worktree|path|HEAD|branch)"

# Create directory for worktree if it doesn't exist
mkdir -p "$TEST_WORKTREE_PATH" 2>/dev/null

# Test: Add a Worktree
run_test "Add a Worktree" \
         "Add a new Git worktree at $TEST_WORKTREE_PATH using the $TEST_BRANCH branch" \
         "(worktree|added|$TEST_WORKTREE_PATH|$TEST_BRANCH)"

# Create directory for new worktree path if it doesn't exist
mkdir -p "$TEST_WORKTREE_NEW_PATH" 2>/dev/null

# Test: Move a Worktree
run_test "Move a Worktree" \
         "Move the Git worktree from $TEST_WORKTREE_PATH to $TEST_WORKTREE_NEW_PATH" \
         "(worktree|moved|$TEST_WORKTREE_PATH|$TEST_WORKTREE_NEW_PATH)"

# Test: Remove a Worktree
run_test "Remove a Worktree" \
         "Remove the Git worktree at $TEST_WORKTREE_NEW_PATH" \
         "(worktree|removed|$TEST_WORKTREE_NEW_PATH)"

# Test: Prune Worktrees
run_test "Prune Worktrees" \
         "Prune all stale Git worktrees in the current repository" \
         "(worktree|pruned|stale)"

# Print summary
print_summary

# Exit with appropriate status code
if [ $FAILED -gt 0 ]; then
  exit 1
else
  exit 0
fi
