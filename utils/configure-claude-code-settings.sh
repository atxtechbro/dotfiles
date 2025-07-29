#!/bin/bash
# Configure Claude Code settings from declarative JSON

set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Find the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Path to settings file
SETTINGS_FILE="$REPO_ROOT/.claude/settings/claude-code-defaults.json"

echo "Configuring Claude Code settings..."

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Settings file not found at $SETTINGS_FILE"
    exit 1
fi

# Apply settings using jq to parse JSON
if command -v jq &> /dev/null; then
    # Extract and apply each setting
    while IFS= read -r key && IFS= read -r value; do
        # Convert camelCase to kebab-case for CLI
        cli_key=$(echo "$key" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]')
        
        echo "Setting $cli_key to $value"
        claude config set --global "$cli_key" "$value" || echo "Warning: Failed to set $cli_key"
    done < <(jq -r 'to_entries[] | .key, .value' "$SETTINGS_FILE")
else
    echo "Error: jq is required to parse settings. Install with: apt-get install jq"
    exit 1
fi

echo -e "${GREEN}Claude Code settings applied successfully!${NC}"