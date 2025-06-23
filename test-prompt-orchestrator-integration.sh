#!/bin/bash
# Test prompt orchestrator integration between dotfiles and lifehacking
# Principle: tracer-bullets

set -euo pipefail

echo "=== Testing Prompt Orchestrator Integration ==="
echo

LIFEHACKING_DIR="$HOME/ppv/pillars/lifehacking"
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"

# Test 1: Verify dotfiles orchestrator works
echo "Test 1: Testing dotfiles prompt orchestrator..."
cd "$DOTFILES_DIR"

# Create a test template
cat > /tmp/test_fitness_template.md << 'EOF'
# Fitness Test Template

Days until competition: {{ DAYS_OUT() }}
Athlete age: {{ ATHLETE_AGE() }}
Current date: {{ CURRENT_DATE() }}

## Injected Principle
{{ INJECT:principles/do-dont-explain.md }}

## Macros Data
{{ TEST_MACROS }}
EOF

# Test with dotfiles orchestrator (shouldn't have fitness functions)
echo "Running with dotfiles orchestrator (expect DAYS_OUT/ATHLETE_AGE to fail)..."
"$DOTFILES_DIR/utils/prompt_orchestrator.py" /tmp/test_fitness_template.md \
    -o /tmp/dotfiles_output.md \
    -k "$DOTFILES_DIR/knowledge" || echo "Expected failure - fitness functions not available"

echo
echo "Test 2: Testing lifehacking prompt orchestrator wrapper..."
cd "$LIFEHACKING_DIR"

# Check current branch and only switch if needed
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Find the correct remote branch
REMOTE_BRANCH=$(git branch -r | grep -E "origin/.*prompt.*orchestrator" | head -1 | xargs)
if [ -n "$REMOTE_BRANCH" ]; then
    echo "Found remote branch: $REMOTE_BRANCH"
    LOCAL_BRANCH=$(echo "$REMOTE_BRANCH" | sed 's|origin/||')
    git checkout -B "$LOCAL_BRANCH" "$REMOTE_BRANCH" || echo "Could not checkout branch, continuing with current"
else
    echo "No prompt orchestrator branch found, using current branch"
fi

# Create test MACROS.json
echo '{
  "calories": 2800,
  "protein": 200,
  "carbs": 350,
  "fat": 78
}' > /tmp/test_macros.json

# Test with lifehacking orchestrator (should have fitness functions)
echo "Running with lifehacking orchestrator (should succeed)..."
"$LIFEHACKING_DIR/scripts/prompt_orchestrator.py" /tmp/test_fitness_template.md \
    -o /tmp/lifehacking_output.md \
    -k "$DOTFILES_DIR/knowledge" \
    -j /tmp/test_macros.json

echo
echo "Test 3: Verify output..."
if [ -f /tmp/lifehacking_output.md ]; then
    echo "Output generated successfully!"
    echo "--- Output Preview ---"
    head -20 /tmp/lifehacking_output.md
    echo "..."
    echo "--- End Preview ---"
    
    # Check if functions were resolved
    if grep -q "DAYS_OUT()" /tmp/lifehacking_output.md; then
        echo "ERROR: DAYS_OUT() was not resolved!"
    else
        echo "SUCCESS: DAYS_OUT() was resolved"
    fi
    
    if grep -q "ATHLETE_AGE()" /tmp/lifehacking_output.md; then
        echo "ERROR: ATHLETE_AGE() was not resolved!"
    else
        echo "SUCCESS: ATHLETE_AGE() was resolved"
    fi
    
    if grep -q "{{ INJECT:" /tmp/lifehacking_output.md; then
        echo "ERROR: Injection placeholders were not resolved!"
    else
        echo "SUCCESS: Injections were resolved"
    fi
else
    echo "ERROR: No output file generated!"
fi

echo
echo "Test 4: Test actual fitness prompt..."
if [ -f "$LIFEHACKING_DIR/fitness/prompts/assessment_prompt.md" ]; then
    echo "Processing actual assessment_prompt.md..."
    "$LIFEHACKING_DIR/scripts/prompt_orchestrator.py" \
        "$LIFEHACKING_DIR/fitness/prompts/assessment_prompt.md" \
        -o /tmp/assessment_output.md \
        -k "$DOTFILES_DIR/knowledge" \
        -j /tmp/test_macros.json \
        --var DAYS_OUT="33"
    
    if [ -f /tmp/assessment_output.md ]; then
        echo "SUCCESS: Assessment prompt processed"
        echo "Word count: $(wc -w < /tmp/assessment_output.md) words"
        
        # Check specific replacements
        if grep -q "33 days" /tmp/assessment_output.md; then
            echo "SUCCESS: DAYS_OUT variable was used"
        fi
    fi
fi

# Cleanup
rm -f /tmp/test_fitness_template.md /tmp/test_macros.json
rm -f /tmp/dotfiles_output.md /tmp/lifehacking_output.md /tmp/assessment_output.md

echo
echo "=== Integration Test Complete ==="