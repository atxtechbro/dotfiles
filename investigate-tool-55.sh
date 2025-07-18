#!/bin/bash
# Investigate Tool #55 - The tool causing the 64-character error
# Based on error: tools.55.custom.name exceeds 64 characters

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/mcp/mcp.json"

echo "=== Investigation: Tool #55 Analysis ==="
echo "Target: Identify tool #55 and potential additional prefixes"
echo ""

# Source work machine detection
source "$SCRIPT_DIR/.bash_aliases.d/work-machine-detection.sh"
work_machine_debug
echo ""

echo "=== Loading Tools in Order ==="
total_count=0
tool_55_found=false

# Process servers in the exact order from MCP config
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
                    ((total_count++))
                    ((server_count++))
                    
                    # Check if this is tool #55
                    if [[ $total_count -eq 55 ]]; then
                        echo "🎯 FOUND TOOL #55!"
                        echo "   Tool name: '$tool_name'"
                        echo "   Length: ${#tool_name} characters"
                        echo "   Server: $server"
                        echo "   Position in server: $server_count"
                        echo ""
                        
                        # Test various prefix combinations
                        echo "🔍 Testing potential prefixes that could cause 64+ character limit:"
                        
                        prefixes=(
                            "custom."
                            "mcp.custom."
                            "server.custom."
                            "$server.custom."
                            "tools.custom."
                            "anthropic.custom."
                            "claude.custom."
                            "fastmcp.custom."
                        )
                        
                        for prefix in "${prefixes[@]}"; do
                            full_name="$prefix$tool_name"
                            length=${#full_name}
                            if [[ $length -gt 64 ]]; then
                                echo "   🚨 '$full_name' = $length chars (EXCEEDS 64!)"
                            elif [[ $length -gt 58 ]]; then
                                echo "   ⚠️  '$full_name' = $length chars (close to limit)"
                            else
                                echo "   ✅ '$full_name' = $length chars (OK)"
                            fi
                        done
                        
                        echo ""
                        echo "🔍 Additional investigation needed:"
                        echo "   - Check if Claude Code adds server name as prefix"
                        echo "   - Look for namespace or module prefixes"
                        echo "   - Investigate if tool descriptions affect naming"
                        echo "   - Check for dynamic prefix generation"
                        
                        tool_55_found=true
                        break
                    fi
                fi
            done <<< "$tool_names"
            
            echo "   Server '$server': $server_count tools (running total: $total_count)"
            
            if [[ $tool_55_found == true ]]; then
                break
            fi
        else
            echo "   Server '$server': No tools loaded"
        fi
    else
        echo "   Server '$server': Wrapper not found"
    fi
    echo ""
done

if [[ $tool_55_found == false ]]; then
    echo "❌ Tool #55 not found!"
    echo "   Total tools loaded: $total_count"
    echo "   This suggests:"
    echo "   1. Different loading order in Claude Code vs our testing"
    echo "   2. Dynamic tool generation we're not seeing"
    echo "   3. Additional MCP servers loaded by Claude Code"
fi

echo ""
echo "=== Summary ==="
echo "Total tools analyzed: $total_count"
echo "Tool #55 found: $tool_55_found"
echo ""
echo "Next steps:"
echo "1. If tool #55 found: Test the identified prefixes"
echo "2. If not found: Investigate Claude Code's actual tool loading order"
echo "3. Look for additional MCP servers or dynamic tool generation"
