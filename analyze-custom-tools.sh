#!/bin/bash
# Comprehensive analysis of tools with 'custom.' prefix to find 64+ character names

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/mcp/mcp.json"

echo "=== Comprehensive Tool Analysis with 'custom.' Prefix ==="
echo "Looking for tools that exceed 64 characters when prefixed with 'custom.'"
echo "Based on error pattern: tools.N.custom.name"
echo ""

# Source work machine detection
source "$SCRIPT_DIR/.bash_aliases.d/work-machine-detection.sh"
work_machine_debug
echo ""

total_count=0
problematic_tools=()

# Get servers from MCP config in the order they appear
servers=$(jq -r '.mcpServers | keys[]' "$MCP_CONFIG")

echo "=== Analyzing each MCP server ==="
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
                    
                    # Calculate with custom prefix
                    custom_name="custom.$tool_name"
                    custom_length=${#custom_name}
                    
                    # Check for problematic lengths
                    if [[ $custom_length -gt 64 ]]; then
                        echo "🚨 PROBLEM FOUND! Tool #$total_count: '$custom_name' ($custom_length chars)"
                        problematic_tools+=("$total_count:$custom_name:$custom_length:$server")
                    fi
                    
                    # Highlight specific tool numbers mentioned in errors
                    if [[ $total_count -eq 55 || $total_count -eq 93 ]]; then
                        echo "🎯 Tool #$total_count: '$custom_name' ($custom_length chars) from $server"
                        if [[ $custom_length -gt 64 ]]; then
                            echo "   ⚠️  THIS TOOL EXCEEDS 64 CHARACTERS!"
                        fi
                    fi
                    
                    # Show tools close to the limit
                    if [[ $custom_length -gt 58 && $custom_length -le 64 ]]; then
                        echo "⚠️  Tool #$total_count: '$custom_name' ($custom_length chars) - Close to limit"
                    fi
                fi
            done <<< "$tool_names"
            
            echo "   Server '$server': $server_count tools (running total: $total_count)"
        else
            echo "   Server '$server': No tools loaded or failed"
        fi
    else
        echo "   Server '$server': Wrapper not found at $wrapper_path"
    fi
    echo ""
done

echo "=== FINAL ANALYSIS ==="
echo "Total tools loaded: $total_count"
echo "Tools exceeding 64 chars with 'custom.' prefix: ${#problematic_tools[@]}"

if [[ ${#problematic_tools[@]} -gt 0 ]]; then
    echo ""
    echo "🚨 PROBLEMATIC TOOLS FOUND:"
    for tool_info in "${problematic_tools[@]}"; do
        IFS=':' read -r num name length server <<< "$tool_info"
        echo "  Tool #$num: $name ($length chars) from server '$server'"
        echo "    Original name: ${name#custom.}"
        echo "    Length without prefix: $((length - 7))"
        echo ""
    done
    
    echo "🔧 SOLUTION: Shorten these tool names in their respective MCP servers"
else
    echo ""
    echo "❓ No tools found exceeding 64 characters with 'custom.' prefix"
    echo "   The error might be caused by:"
    echo "   1. Dynamic tool generation under specific conditions"
    echo "   2. Different tool loading order in Claude Code vs our testing"
    echo "   3. Additional prefixes beyond 'custom.'"
    echo "   4. Tool name modifications during Claude Code startup"
fi
