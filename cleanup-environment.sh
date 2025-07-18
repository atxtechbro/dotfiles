#!/bin/bash
# Environment Cleanup Script
# Resolves conflicts and inconsistencies in shell environment

set -euo pipefail

echo "=== Environment Cleanup Script ==="
echo "This script will clean up conflicting environment variables and configurations"

# 1. Clean up conflicting Bedrock variables
echo "1. Cleaning up Bedrock configuration conflicts..."
unset CLAUDE_CODE_USE_BEDROCK 2>/dev/null || true
unset CLAUDE_USE_BEDROCK 2>/dev/null || true  
unset DISABLE_BEDROCK 2>/dev/null || true

echo "   ✓ Cleared conflicting Bedrock variables"

# 2. Ensure work machine detection is properly loaded
echo "2. Reinitializing work machine detection..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.bash_aliases.d/work-machine-detection.sh"
work_machine_debug

# 3. Clean up duplicate PATH entries
echo "3. Cleaning up PATH duplicates..."
# Remove duplicates while preserving order
NEW_PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
export PATH="$NEW_PATH"
echo "   ✓ Cleaned PATH duplicates"

# 4. Reload shell configuration cleanly
echo "4. Reloading shell configuration..."
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
    echo "   ✓ Reloaded ~/.bashrc"
fi

# 5. Verify MCP configuration
echo "5. Verifying MCP configuration..."
MCP_CONFIG="$SCRIPT_DIR/mcp/mcp.json"
if [[ -f "$MCP_CONFIG" ]]; then
    echo "   ✓ MCP config found at: $MCP_CONFIG"
    echo "   Servers configured: $(jq -r '.mcpServers | keys | length' "$MCP_CONFIG")"
else
    echo "   ❌ MCP config not found!"
fi

echo ""
echo "=== Cleanup Complete ==="
echo "Environment should now be clean and consistent."
echo "Try running Claude Code again to see if the error persists."
