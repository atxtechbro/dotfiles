#!/bin/bash
# Test script to verify that terminal startup produces no unwanted output
# This simulates opening a new terminal and captures any output
# Specifically focuses on catching git branch errors in non-git directories

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

echo "Testing in non-git directory: $TEST_DIR"

# Test the parse_git_branch function directly by creating a test script
echo "Testing parse_git_branch function directly..."
cat > "$TEST_DIR/test_git_branch.sh" << 'EOF'
#!/bin/bash
# Source the bashrc to get the function definition
source ~/.bashrc

# Force PS1 evaluation which will call parse_git_branch
PROMPT=$(PS1='\W$(parse_git_branch) $ ' bash -i -c 'echo $PS1' 2>&1)

# Check for git errors
if echo "$PROMPT" | grep -q "fatal: not a git repository"; then
    echo "Git error detected in prompt evaluation"
    echo "$PROMPT"
    exit 1
fi

exit 0
EOF

chmod +x "$TEST_DIR/test_git_branch.sh"

# Run the test script and capture output
"$TEST_DIR/test_git_branch.sh" > "$TEMP_OUTPUT" 2>&1

# Check if the test script found errors
if [ $? -ne 0 ]; then
    echo "❌ Test failed: parse_git_branch function produced git errors:"
    echo "-----------------------------------"
    cat "$TEMP_OUTPUT"
    echo "-----------------------------------"
    
    echo "The git branch function in .bashrc needs to be fixed to properly redirect stderr."
    echo "Suggested fix:"
    echo "parse_git_branch() {"
    echo "  if git rev-parse --is-inside-work-tree &>/dev/null; then"
    echo "    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'"
    echo "  fi"
    echo "}"
    
    rm -f "$TEMP_OUTPUT"
    rm -rf "$TEST_DIR"
    exit 1
else
    echo "✅ Test passed: No git errors in parse_git_branch function"
    rm -f "$TEMP_OUTPUT"
    rm -rf "$TEST_DIR"
    exit 0
fi
