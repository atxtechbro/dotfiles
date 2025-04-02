#!/bin/bash
# Test script to verify that terminal startup produces no unwanted output
# This simulates opening a new terminal and captures any output

echo "Running terminal startup test..."

# Create a temporary file to capture output
TEMP_OUTPUT=$(mktemp)

# Simulate a login shell with dotfiles loaded
# The -l flag makes bash act as a login shell
# We redirect both stdout and stderr to our temp file
bash -l -c "exit" > "$TEMP_OUTPUT" 2>&1

# Check if there was any output
if [ -s "$TEMP_OUTPUT" ]; then
    echo "❌ Test failed: Terminal startup produced unexpected output:"
    echo "-----------------------------------"
    cat "$TEMP_OUTPUT"
    echo "-----------------------------------"
    rm "$TEMP_OUTPUT"
    exit 1
else
    echo "✅ Test passed: Terminal startup produced no output"
    rm "$TEMP_OUTPUT"
    exit 0
fi
