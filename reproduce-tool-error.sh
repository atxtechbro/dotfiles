#!/bin/bash
# Reliable reproduction script for Claude Code 64-character tool name error
# Based on observed error pattern: tools.N.custom.name exceeds 64 characters

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/claude-error-reproduction.log"

echo "=== Claude Code Tool Name Error Reproduction Script ==="
echo "Target Error: API Error: 400 tools.N.custom.name: String should have at most 64 characters"
echo "Log file: $LOG_FILE"
echo ""

# Ensure clean environment
echo "1. Setting up clean environment..."
cd "$SCRIPT_DIR"
source .bash_aliases.d/work-machine-detection.sh
work_machine_debug

# Clear any existing log
> "$LOG_FILE"

echo ""
echo "2. Attempting to reproduce error with different methods..."

# Method 1: Direct command with minimal input
echo "Method 1: Direct command with minimal input"
attempt=1
max_attempts=5

while [[ $attempt -le $max_attempts ]]; do
    echo "  Attempt $attempt/$max_attempts..."
    
    # Try to trigger the error with a simple command
    if timeout 10 bash -c 'echo "test" | claude 2>&1' >> "$LOG_FILE" 2>&1; then
        echo "    Command completed without timeout"
    else
        echo "    Command timed out or failed"
    fi
    
    # Check if we caught the error
    if grep -q "tools\.[0-9]*\.custom\.name.*64 characters" "$LOG_FILE"; then
        echo "    ✅ ERROR REPRODUCED!"
        error_line=$(grep "tools\.[0-9]*\.custom\.name.*64 characters" "$LOG_FILE" | tail -1)
        echo "    Error: $error_line"
        
        # Extract tool number
        tool_number=$(echo "$error_line" | sed -n 's/.*tools\.\([0-9]*\)\.custom\.name.*/\1/p')
        echo "    Problematic tool number: $tool_number"
        
        echo ""
        echo "3. SUCCESS: Error reproduced reliably!"
        echo "   Method: Direct stdin input to claude command"
        echo "   Tool number: $tool_number"
        echo "   Full log saved to: $LOG_FILE"
        
        exit 0
    fi
    
    ((attempt++))
    sleep 1
done

echo "  Method 1 failed to reproduce error after $max_attempts attempts"

# Method 2: Try with different input patterns
echo ""
echo "Method 2: Testing with different input patterns..."

test_inputs=("help" "status" "test error" "list tools" "a" "x" ".")

for input in "${test_inputs[@]}"; do
    echo "  Testing with input: '$input'"
    
    if timeout 8 bash -c "echo '$input' | claude 2>&1" >> "$LOG_FILE" 2>&1; then
        if grep -q "tools\.[0-9]*\.custom\.name.*64 characters" "$LOG_FILE"; then
            echo "    ✅ ERROR REPRODUCED with input: '$input'"
            error_line=$(grep "tools\.[0-9]*\.custom\.name.*64 characters" "$LOG_FILE" | tail -1)
            tool_number=$(echo "$error_line" | sed -n 's/.*tools\.\([0-9]*\)\.custom\.name.*/\1/p')
            
            echo ""
            echo "3. SUCCESS: Error reproduced reliably!"
            echo "   Method: Input '$input' via stdin"
            echo "   Tool number: $tool_number"
            echo "   Error: $error_line"
            echo "   Full log saved to: $LOG_FILE"
            
            exit 0
        fi
    fi
done

echo "  Method 2 failed to reproduce error with various inputs"

# Method 3: Try interactive startup without input
echo ""
echo "Method 3: Testing interactive startup (no input)..."

if timeout 5 claude < /dev/null >> "$LOG_FILE" 2>&1; then
    if grep -q "tools\.[0-9]*\.custom\.name.*64 characters" "$LOG_FILE"; then
        echo "    ✅ ERROR REPRODUCED during startup!"
        error_line=$(grep "tools\.[0-9]*\.custom\.name.*64 characters" "$LOG_FILE" | tail -1)
        tool_number=$(echo "$error_line" | sed -n 's/.*tools\.\([0-9]*\)\.custom\.name.*/\1/p')
        
        echo ""
        echo "3. SUCCESS: Error reproduced reliably!"
        echo "   Method: Interactive startup (no input required)"
        echo "   Tool number: $tool_number"
        echo "   Error: $error_line"
        echo "   Full log saved to: $LOG_FILE"
        
        exit 0
    fi
fi

echo "  Method 3 failed to reproduce error during startup"

echo ""
echo "❌ REPRODUCTION FAILED"
echo "   None of the methods successfully reproduced the error"
echo "   This suggests the error may be:"
echo "   1. Timing-dependent (race condition)"
echo "   2. Environment-dependent (specific state required)"
echo "   3. Network-dependent (API response timing)"
echo "   4. Load-dependent (system resource availability)"
echo ""
echo "Full log saved to: $LOG_FILE"
echo "Manual reproduction steps observed:"
echo "   1. cd /Users/morgan.joyce/ppv/pillars/dotfiles"
echo "   2. claude (interactive mode)"
echo "   3. Type any short input (e.g., 'asa', 'test')"
echo "   4. Error appears: tools.N.custom.name exceeds 64 characters"

exit 1
