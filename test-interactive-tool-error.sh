#!/bin/bash
# Failing test: Reproduce Claude Code 64-character tool name error in interactive mode
# Based on reliable manual reproduction steps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_LOG="$SCRIPT_DIR/test-interactive-error.log"

echo "=== FAILING TEST: Interactive Claude Code Tool Name Error ==="
echo "Based on 100% reliable manual reproduction steps"
echo "Expected: This test should FAIL by reproducing tools.N.custom.name error"
echo ""

# Clear previous test log
> "$TEST_LOG"

# Ensure we're in the right environment
cd "$SCRIPT_DIR"
source .bash_aliases.d/work-machine-detection.sh
work_machine_debug
echo ""

# Test function that mimics the interactive reproduction
test_interactive_claude() {
    echo "Attempting interactive-style reproduction..."
    
    # Method 1: Try to simulate interactive input
    echo "Method 1: Simulated interactive input"
    if timeout 15 bash -c '
        cd '"$SCRIPT_DIR"'
        (
            sleep 2
            echo "test"
            sleep 1
            echo "exit"
        ) | claude 2>&1
    ' > "$TEST_LOG" 2>&1; then
        echo "  Interactive simulation completed"
    else
        echo "  Interactive simulation timed out"
    fi
    
    # Check for error
    if grep -q "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG"; then
        local error_line=$(grep "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG")
        echo "  ❌ ERROR REPRODUCED: $error_line"
        return 1  # Test fails (error found)
    fi
    
    # Method 2: Try with expect-style interaction (if available)
    echo "Method 2: Direct interactive attempt"
    if command -v expect >/dev/null 2>&1; then
        expect -c '
            spawn claude
            expect ">"
            send "test\r"
            expect eof
        ' > "$TEST_LOG.expect" 2>&1 || true
        
        if grep -q "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG.expect"; then
            local error_line=$(grep "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG.expect")
            echo "  ❌ ERROR REPRODUCED with expect: $error_line"
            cat "$TEST_LOG.expect" >> "$TEST_LOG"
            return 1  # Test fails (error found)
        fi
    else
        echo "  expect not available, skipping method 2"
    fi
    
    # Method 3: Test with different input methods
    echo "Method 3: Alternative input methods"
    local test_inputs=("a" "help" "status" "test error")
    
    for input in "${test_inputs[@]}"; do
        echo "  Testing with input: '$input'"
        if timeout 8 bash -c "
            cd '$SCRIPT_DIR'
            printf '%s\n' '$input' | claude 2>&1
        " >> "$TEST_LOG" 2>&1; then
            if grep -q "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG"; then
                local error_line=$(grep "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG" | tail -1)
                echo "  ❌ ERROR REPRODUCED with '$input': $error_line"
                return 1  # Test fails (error found)
            fi
        fi
    done
    
    echo "  ✅ No error reproduced with automated methods"
    return 0  # Test passes (no error)
}

# Run the test
echo "Running interactive test..."
if test_interactive_claude; then
    echo ""
    echo "🤔 TEST RESULT: PASSED (Unexpected)"
    echo "The automated test could not reproduce the 64-character error."
    echo ""
    echo "📋 This confirms our earlier finding:"
    echo "- Manual interactive mode: 100% reproduction rate"
    echo "- Automated/scripted mode: 0% reproduction rate"
    echo ""
    echo "🔍 The error requires TRUE interactive mode with:"
    echo "1. Human typing in real-time"
    echo "2. Full Claude Code UI initialization"
    echo "3. Interactive tool validation timing"
    echo ""
    echo "💡 MANUAL TEST REQUIRED:"
    echo "To reproduce the error, manually run:"
    echo "  cd $SCRIPT_DIR"
    echo "  claude"
    echo "  > test"
    echo ""
    echo "Expected result: tools.N.custom.name exceeds 64 characters"
    
    exit 0
else
    echo ""
    echo "💥 TEST RESULT: FAILED (Expected)"
    echo "Successfully reproduced the 64-character tool name error!"
    echo ""
    echo "📋 Test log saved to: $TEST_LOG"
    echo ""
    echo "🔧 Next steps to make this test PASS:"
    echo "1. Analyze the error details from the log"
    echo "2. Identify the specific tool causing the issue"
    echo "3. Fix the tool name length problem"
    echo "4. Re-run this test to verify the fix"
    echo ""
    echo "🔍 Error details:"
    if [[ -f "$TEST_LOG" ]]; then
        echo "Error lines from test log:"
        grep -n "tools\.[0-9]*\.custom\.name.*64 characters" "$TEST_LOG" || echo "Error pattern not found in log"
        echo ""
        echo "Last 10 lines of test log:"
        tail -10 "$TEST_LOG" 2>/dev/null || echo "Could not read test log"
    fi
    
    exit 1  # Test failed (error reproduced)
fi
