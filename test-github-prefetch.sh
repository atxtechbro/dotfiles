#!/bin/bash
# Test script for GitHub prefetch implementation

set -euo pipefail

echo "=== Testing GitHub Issue Prefetch ==="
echo ""

# Source the prefetch script
source utils/prefetch-github-issue.sh

# Test with issue 981 (this issue)
echo "Testing with issue #981..."
export ISSUE_NUMBER=981

# Call the prefetch function
if prefetch_issue_data "$ISSUE_NUMBER"; then
    echo ""
    echo "Prefetch successful! Exported variables:"
    echo "  ISSUE_STATE: $ISSUE_STATE"
    echo "  ISSUE_TITLE: $ISSUE_TITLE"
    echo "  ISSUE_LABELS: $ISSUE_LABELS"
    echo "  ISSUE_ASSIGNEES: $ISSUE_ASSIGNEES"
    echo "  ISSUE_COMMENTS length: $(echo "$ISSUE_COMMENTS" | jq '. | length') comments"
    echo ""
    echo "✅ Prefetch test passed!"
else
    echo "❌ Prefetch test failed!"
    exit 1
fi

echo ""
echo "=== Testing Command Generation ==="
echo ""

# Run generate-commands.sh to test integration
cd /home/linuxmint-lp/ppv/pillars/dotfiles/worktrees/feature/github-api-prefetch-981
if ./utils/generate-commands.sh; then
    echo ""
    echo "✅ Command generation test passed!"
    
    # Check if the generated command includes prefetch
    if grep -q "prefetch_issue_data" ~/.claude/commands/close-issue.md; then
        echo "✅ Prefetch integration confirmed in generated command!"
    else
        echo "❌ Prefetch not found in generated command"
    fi
else
    echo "❌ Command generation test failed!"
fi