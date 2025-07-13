#!/bin/bash
# Claude Code global configuration (MCP + settings)
# This ensures Claude Code uses both MCP servers and settings from dotfiles globally

# Define the global config locations
# DOT_DEN is set by setup.sh, fallback to home dotfiles if not set
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
GLOBAL_MCP_CONFIG="$DOT_DEN/mcp/mcp.json"
GLOBAL_SETTINGS="$DOT_DEN/.claude/settings.json"

# Main Claude wrapper that applies both MCP config and settings
claude() {
    # Export environment variables from settings.json
    if [ -f "$GLOBAL_SETTINGS" ] && command -v jq &> /dev/null; then
        while IFS='=' read -r key value; do
            export "$key=$value"
        done < <(jq -r '.env | to_entries[] | "\(.key)=\(.value)"' "$GLOBAL_SETTINGS" 2>/dev/null)
    fi

    # Extract allowed tools from settings.json
    local allowed_tools=""
    if [ -f "$GLOBAL_SETTINGS" ] && command -v jq &> /dev/null; then
        allowed_tools=$(jq -r '.permissions.allow[]' "$GLOBAL_SETTINGS" 2>/dev/null | tr '\n' ' ')
    fi

    # Build command with both MCP config and allowed tools
    local cmd=(command claude --mcp-config "$GLOBAL_MCP_CONFIG")
    
    if [ -n "$allowed_tools" ]; then
        cmd+=(--allowedTools "$allowed_tools")
    fi
    
    # Execute with all arguments
    "${cmd[@]}" "$@"
}

# Variant that strictly uses only the global configs
alias claude-global='claude --strict-mcp-config'

# Function to check all global configurations
claude-global-info() {
    echo "=== Claude Code Global Configuration ==="
    echo ""
    echo "MCP Configuration:"
    echo "  Path: $GLOBAL_MCP_CONFIG"
    if [ -f "$GLOBAL_MCP_CONFIG" ]; then
        echo "  ✓ MCP config exists"
        echo "  Available MCP servers:"
        jq -r '.mcpServers | keys[]' "$GLOBAL_MCP_CONFIG" 2>/dev/null | sed 's/^/    - /' || echo "    (unable to parse)"
    else
        echo "  ✗ MCP config not found!"
    fi
    
    echo ""
    echo "Settings Configuration:"
    echo "  Path: $GLOBAL_SETTINGS"
    if [ -f "$GLOBAL_SETTINGS" ]; then
        echo "  ✓ Settings file exists"
        echo "  Environment variables:"
        jq -r '.env | to_entries[] | "    \(.key)=\(.value)"' "$GLOBAL_SETTINGS" 2>/dev/null || echo "    (unable to parse)"
        echo "  Permissions: $(jq -r '.permissions.allow | length' "$GLOBAL_SETTINGS" 2>/dev/null || echo "?") allowed tools"
    else
        echo "  ✗ Settings file not found!"
    fi
    
    echo ""
    echo "Note: Settings wrapper active for environment variables and permissions"
}

# Backwards compatibility
alias claude-mcp-info='claude-global-info'

# Test function to verify settings are applied
claude-test-settings() {
    echo "Testing Claude Code global settings..."
    echo ""
    echo "Environment variables from dotfiles:"
    
    if [ -f "$GLOBAL_SETTINGS" ] && command -v jq &> /dev/null; then
        while IFS='=' read -r key expected; do
            current_value="${!key}"
            if [ -n "$current_value" ]; then
                if [ "$current_value" = "$expected" ]; then
                    echo "  ✓ $key=$current_value"
                else
                    echo "  ⚠ $key=$current_value (expected: $expected)"
                fi
            else
                echo "  ✗ $key (not set, expected: $expected)"
            fi
        done < <(jq -r '.env | to_entries[] | "\(.key)=\(.value)"' "$GLOBAL_SETTINGS" 2>/dev/null)
    else
        echo "  Unable to read settings file"
    fi
    
    echo ""
    echo "To verify in a Claude session:"
    echo '  claude "echo \$CLAUDE_CODE_MAX_OUTPUT_TOKENS"'
    echo "  Expected output: 8192"
}

# Optional: Completion for the wrapper function
if command -v claude >/dev/null 2>&1; then
    # Use function completion instead of alias completion
    complete -F _claude claude 2>/dev/null || true
    complete -F _claude claude-global 2>/dev/null || true
fi