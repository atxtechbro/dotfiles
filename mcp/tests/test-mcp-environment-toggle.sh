#!/bin/bash

# Enable debug mode to see all commands as they're executed
set -x

# Add early exit on first failure
set -e

# =========================================================
# TEST HARNESS FOR MCP ENVIRONMENT TOGGLE
# =========================================================

# Import the test harness library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/test-harness.sh"

# Enable exit on first failure
export EXIT_ON_FIRST_FAILURE=true

# Initialize test suite
init_test_suite "MCP ENVIRONMENT TOGGLE" "Environment"

# Save original hostname for restoration later
ORIGINAL_HOSTNAME=$(hostname)

# Function to run cleanup operations
cleanup() {
  echo -e "\n${BLUE}CLEANUP:${NC} Restoring original environment"
  # No need to actually change the hostname back as we're just overriding it for the command
  echo "Cleanup complete"
}

# Run cleanup on script exit
trap cleanup EXIT

# Test: Personal Environment (non-work hostname)
run_test "Personal Environment Disables Atlassian" \
         "HOSTNAME=personal-laptop MCP_DISABLE_ATLASSIAN=true ./bin/mcp-wrapper.sh mcp list | grep -v atlassian" \
         ".*" # Simple pattern to match any output that doesn't contain atlassian

# Test: Work Environment (work hostname)
run_test "Work Environment Enables Atlassian" \
         "HOSTNAME=work-laptop $TEST_MODEL chat --no-interactive --trust-all-tools \"List all available MCP servers\"" \
         ".*atlassian.*" # Ensure atlassian IS present

# Test: Corporate Environment (corp hostname)
run_test "Corporate Environment Enables Atlassian" \
         "HOSTNAME=corp-laptop $TEST_MODEL chat --no-interactive --trust-all-tools \"List all available MCP servers\"" \
         ".*atlassian.*" # Ensure atlassian IS present

# Test: Manual Override - Enable on Personal
run_test "Manual Override Enables Atlassian on Personal" \
         "HOSTNAME=personal-laptop MCP_DISABLE_ATLASSIAN=false $TEST_MODEL chat --no-interactive --trust-all-tools \"List all available MCP servers\"" \
         ".*atlassian.*" # Ensure atlassian IS present despite personal hostname

# Test: Manual Override - Disable on Work
run_test "Manual Override Disables Atlassian on Work" \
         "HOSTNAME=work-laptop MCP_DISABLE_ATLASSIAN=true $TEST_MODEL chat --no-interactive --trust-all-tools \"List all available MCP servers\"" \
         "(?!.*atlassian).*" # Ensure atlassian is NOT present despite work hostname

# Print test summary
print_summary
