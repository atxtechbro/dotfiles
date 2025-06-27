#!/bin/bash
# Configure Claude Code settings from source-controlled defaults
# Applies settings defined in .claude/settings/claude-code-defaults.json

# Don't use set -e when this script might be sourced
# It would affect the parent shell and cause exits
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly, safe to use strict mode
    set -euo pipefail
fi

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

configure_claude_code_settings() {
    echo "Configuring Claude Code settings..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    DOT_DEN="$(dirname "$SCRIPT_DIR")"
    
    # Path to source settings
    SETTINGS_SOURCE="$DOT_DEN/.claude/settings/claude-code-defaults.json"
    
    # Check if Claude Code is installed
    if ! command -v claude &> /dev/null; then
        echo -e "${YELLOW}Claude Code is not installed. Skipping configuration.${NC}"
        return 0
    fi
    
    # Check if settings file exists
    if [ ! -f "$SETTINGS_SOURCE" ]; then
        echo -e "${YELLOW}No Claude Code settings found at $SETTINGS_SOURCE${NC}"
        return 0
    fi
    
    # Check if jq is available for JSON parsing
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is not installed. Cannot parse JSON settings.${NC}"
        return 1
    fi
    
    # Apply each setting from the JSON file
    echo "Applying Claude Code settings from source control..."
    
    # Read each key-value pair from the JSON file
    while IFS= read -r key && IFS= read -r value; do
        # Skip empty keys
        if [ -z "$key" ]; then
            continue
        fi
        
        # Apply the setting globally
        if claude config set --global "$key" "$value" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Set $key to: $value"
        else
            echo -e "  ${RED}✗${NC} Failed to set $key"
        fi
    done < <(jq -r 'to_entries[] | .key, .value' "$SETTINGS_SOURCE")
    
    echo -e "${GREEN}✓ Claude Code settings configured${NC}"
    
    # Show current configuration
    echo -e "\nCurrent Claude Code global settings:"
    claude config list --global 2>/dev/null | grep -E "(theme|editorMode|preferredNotifChannel|todoFeatureEnabled|autoConnectIde)" || true
    
    # Platform-specific notes
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "\n${YELLOW}macOS Note:${NC}"
        echo "For terminal bell notifications to work in iTerm2:"
        echo "  1. Go to System Settings → Notifications → iTerm2"
        echo "  2. Enable 'Allow Notifications'"
        echo "  3. In iTerm2: Preferences → Profiles → Terminal → Check 'Enable bell'"
    fi
    
    return 0
}

# Run configuration if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_claude_code_settings
fi