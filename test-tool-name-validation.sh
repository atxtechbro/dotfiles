#!/bin/bash
# Test: Validate all MCP tool names are under 64 characters with potential prefixes
# This test should PASS when the issue is fixed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/mcp/mcp.json"

echo "=== TOOL NAME LENGTH VALIDATION TEST ==="
echo "Goal: Ensure all MCP tool names are under 64 characters with prefixes"
echo "This test should PASS when the 64-character issue is resolved"
echo ""

# Source work machine detection
source "$SCRIPT_DIR/.bash_aliases.d/work-machine-detection.sh"
work_machine_debug
echo ""

# Test configuration
MAX_LENGTH=64
KNOWN_PREFIXES=(
    "custom."
    "mcp.custom."
    "server.custom."
    "tools.custom."
    "anthropic.custom."
    "claude.custom."
    "fastmcp.custom."
)

# Track test results
total_tools=0
violations=()
warnings=()

echo "=== Analyzing MCP Tool Names ==="
echo "Maximum allowed length: $MAX_LENGTH characters"
echo "Testing prefixes: ${KNOWN_PREFIXES[*]}"
echo ""

# Get servers from MCP config
servers=$(jq -r '.mcpServers | keys[]' "$MCP_CONFIG")

for server in $servers; do
    echo "--- Server: $server ---"
    
    command=$(jq -r ".mcpServers[\"$server\"].command" "$MCP_CONFIG")
    wrapper_path="$SCRIPT_DIR/mcp/$command"
    
    if [[ -f "$wrapper_path" ]]; then
        # Get tools from this server
        tools_json=$(timeout 10 bash -c "
            echo '{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"initialize\", \"params\": {\"protocolVersion\": \"2024-11-05\", \"capabilities\": {}, \"clientInfo\": {\"name\": \"debug\", \"version\": \"1.0.0\"}}}
{\"jsonrpc\": \"2.0\", \"method\": \"notifications/initialized\"}
{\"jsonrpc\": \"2.0\", \"id\": 2, \"method\": \"tools/list\"}' | '$wrapper_path' 2>/dev/null | tail -1
        " 2>/dev/null || echo '{"result":{"tools":[]}}')
        
        tool_names=$(echo "$tools_json" | jq -r '.result.tools[]?.name // empty' 2>/dev/null || echo "")
        
        if [[ -n "$tool_names" ]]; then
            server_count=0
            while IFS= read -r tool_name; do
                if [[ -n "$tool_name" ]]; then
                    ((total_tools++))
                    ((server_count++))
                    
                    # Test each prefix
                    for prefix in "${KNOWN_PREFIXES[@]}"; do
                        full_name="$prefix$tool_name"
                        length=${#full_name}
                        
                        if [[ $length -gt $MAX_LENGTH ]]; then
                            echo "  ❌ VIOLATION: '$full_name' = $length chars (exceeds $MAX_LENGTH)"
                            violations+=("$server:$tool_name:$prefix:$length")
                        elif [[ $length -gt 58 ]]; then
                            echo "  ⚠️  WARNING: '$full_name' = $length chars (close to limit)"
                            warnings+=("$server:$tool_name:$prefix:$length")
                        fi
                    done
                    
                    # Special attention to tool #55 (get_issue)
                    if [[ $total_tools -eq 55 ]]; then
                        echo "  🎯 Tool #55: '$tool_name' (the problematic tool from error)"
                        echo "     Testing additional potential prefixes..."
                        
                        # Test more exotic prefixes that might cause the issue
                        exotic_prefixes=(
                            "$server.custom."
                            "github-read.mcp.custom."
                            "anthropic.claude.custom."
                            "fastmcp.server.custom."
                            "mcp.server.$server.custom."
                        )
                        
                        for prefix in "${exotic_prefixes[@]}"; do
                            full_name="$prefix$tool_name"
                            length=${#full_name}
                            echo "     '$full_name' = $length chars"
                            
                            if [[ $length -gt $MAX_LENGTH ]]; then
                                echo "     ❌ FOUND VIOLATION WITH EXOTIC PREFIX!"
                                violations+=("$server:$tool_name:$prefix:$length")
                            fi
                        done
                    fi
                fi
            done <<< "$tool_names"
            
            echo "   Server '$server': $server_count tools"
        else
            echo "   Server '$server': No tools loaded"
        fi
    else
        echo "   Server '$server': Wrapper not found"
    fi
    echo ""
done

echo "=== TEST RESULTS ==="
echo "Total tools analyzed: $total_tools"
echo "Violations found: ${#violations[@]}"
echo "Warnings (close to limit): ${#warnings[@]}"
echo ""

if [[ ${#violations[@]} -eq 0 ]]; then
    echo "✅ TEST PASSED: No tool name length violations found"
    echo "All tool names are under $MAX_LENGTH characters with tested prefixes"
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo ""
        echo "⚠️  WARNINGS (tools close to limit):"
        for warning in "${warnings[@]}"; do
            IFS=':' read -r server tool prefix length <<< "$warning"
            echo "  $server/$tool with '$prefix' = $length chars"
        done
        echo ""
        echo "Consider shortening these tool names as a precaution"
    fi
    
    echo ""
    echo "🤔 MYSTERY REMAINS:"
    echo "No violations found with tested prefixes, but error still occurs."
    echo "This suggests Claude Code uses a different/longer prefix than we've tested."
    echo ""
    echo "🔍 Next investigation steps:"
    echo "1. Find the actual prefix Claude Code uses (longer than tested ones)"
    echo "2. Look for dynamic prefix generation based on context"
    echo "3. Check if tool descriptions or metadata affect naming"
    
    exit 0
else
    echo "❌ TEST FAILED: Tool name length violations found"
    echo ""
    echo "🚨 VIOLATIONS:"
    for violation in "${violations[@]}"; do
        IFS=':' read -r server tool prefix length <<< "$violation"
        echo "  $server/$tool with '$prefix' = $length chars (exceeds $MAX_LENGTH)"
    done
    echo ""
    echo "🔧 TO FIX:"
    echo "Shorten the tool names in the problematic MCP servers:"
    
    # Group violations by server
    declare -A server_violations
    for violation in "${violations[@]}"; do
        IFS=':' read -r server tool prefix length <<< "$violation"
        if [[ -z "${server_violations[$server]:-}" ]]; then
            server_violations[$server]="$tool"
        else
            server_violations[$server]="${server_violations[$server]}, $tool"
        fi
    done
    
    for server in "${!server_violations[@]}"; do
        echo "  Server '$server': ${server_violations[$server]}"
    done
    
    exit 1
fi
