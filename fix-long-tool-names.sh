#!/bin/bash
# Fix: Shorten problematic tool names that exceed 64 characters with prefixes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== FIX: Shorten Long Tool Names ==="
echo "Target: Fix tools that exceed 64 characters with prefixes"
echo ""

# The problematic tool we identified:
# github-write/add_pull_request_review_comment_to_pending_review (49 chars)
# With 'anthropic.custom.' prefix = 66 chars (exceeds 64)

echo "🎯 IDENTIFIED PROBLEM:"
echo "Tool: add_pull_request_review_comment_to_pending_review (49 chars)"
echo "With prefix 'anthropic.custom.': 66 chars (exceeds 64-char limit)"
echo ""

echo "🔧 PROPOSED FIX:"
echo "Shorten tool name to: add_pr_review_comment_to_pending_review (37 chars)"
echo "With prefix 'anthropic.custom.': 54 chars (under 64-char limit)"
echo ""

# Check if we can find and modify the GitHub MCP server
GITHUB_SERVER_PATH="$SCRIPT_DIR/mcp/servers/github-mcp-server"

if [[ -d "$GITHUB_SERVER_PATH" ]]; then
    echo "📁 Found GitHub MCP server at: $GITHUB_SERVER_PATH"
    
    # Look for the tool definition
    echo "🔍 Searching for tool definition..."
    
    if find "$GITHUB_SERVER_PATH" -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.ts" | xargs grep -l "add_pull_request_review_comment_to_pending_review" 2>/dev/null; then
        echo "✅ Found tool definition files"
        
        echo ""
        echo "🛠️  MANUAL FIX REQUIRED:"
        echo "1. Edit the GitHub MCP server source code"
        echo "2. Change tool name from:"
        echo "   'add_pull_request_review_comment_to_pending_review'"
        echo "   to:"
        echo "   'add_pr_review_comment_to_pending_review'"
        echo ""
        echo "3. Files to check:"
        find "$GITHUB_SERVER_PATH" -name "*.py" -o -name "*.go" -o -name "*.js" -o -name "*.ts" | xargs grep -l "add_pull_request_review_comment_to_pending_review" 2>/dev/null || echo "   No files found with grep"
        
    else
        echo "❓ Tool definition not found in expected location"
        echo "   The tool might be dynamically generated or in a different location"
    fi
else
    echo "❓ GitHub MCP server directory not found"
    echo "   Expected location: $GITHUB_SERVER_PATH"
fi

echo ""
echo "🧪 ALTERNATIVE APPROACH:"
echo "If we can't modify the source, we could:"
echo "1. Create a wrapper that renames tools"
echo "2. Use a different MCP server with shorter tool names"
echo "3. Configure Claude Code to use shorter prefixes"

echo ""
echo "📋 VERIFICATION STEPS:"
echo "After making the fix:"
echo "1. Restart any MCP servers"
echo "2. Run: ./test-tool-name-validation.sh"
echo "3. Test Claude Code interactively to confirm error is resolved"

echo ""
echo "🎯 EXPECTED OUTCOME:"
echo "Tool name validation test should PASS"
echo "Claude Code should no longer show 64-character error"
