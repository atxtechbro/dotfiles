#!/bin/bash
# Test script to verify that terminal startup produces no unwanted output
# This simulates opening a new terminal and captures any output

echo "Running terminal startup test..."

# Create a temporary file to capture output
TEMP_OUTPUT=$(mktemp)

# Create a non-git directory to test in
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Verify we're not in a git repository
if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: Test directory is unexpectedly a git repository"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Simulate a login shell with dotfiles loaded
# The -l flag makes bash act as a login shell
# We redirect both stdout and stderr to our temp file
# The --norc flag ensures we don't use any local .bashrc that might override our dotfiles
bash --norc -l -c "cd $TEST_DIR && source ~/.bashrc && exit" > "$TEMP_OUTPUT" 2>&1

# Check if there was any output
if [ -s "$TEMP_OUTPUT" ]; then
    echo "❌ Test failed: Terminal startup produced unexpected output:"
    echo "-----------------------------------"
    cat "$TEMP_OUTPUT"
    echo "-----------------------------------"
    rm "$TEMP_OUTPUT"
    rm -rf "$TEST_DIR"
    exit 1
else
    echo "✅ Test passed: Terminal startup produced no output"
    rm "$TEMP_OUTPUT"
    rm -rf "$TEST_DIR"
    exit 0
fi
