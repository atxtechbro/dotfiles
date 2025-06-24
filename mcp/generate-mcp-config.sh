#!/bin/bash

# Simple MCP config generator from template
# Uses sed to process {{#if WORK_MACHINE}} conditionals

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/mcp.template.json"
OUTPUT="$SCRIPT_DIR/mcp.json"

# Check if template exists
if [[ ! -f "$TEMPLATE" ]]; then
    echo "❌ Error: Template file not found: $TEMPLATE"
    exit 1
fi

# Check if we're on a work machine
# IS_PERSONAL_MACHINE is true when WORK_MACHINE is not "true"
if [ "${WORK_MACHINE:-false}" = "true" ]; then
    IS_PERSONAL_MACHINE="false"
else
    IS_PERSONAL_MACHINE="true"
fi

echo "🔧 Generating mcp.json from template..."
echo "📍 Machine type: $([ "$IS_PERSONAL_MACHINE" = "true" ] && echo "personal" || echo "work")"

# Simple substitution - replace {{IS_PERSONAL_MACHINE}} with actual value
sed "s/{{IS_PERSONAL_MACHINE}}/$IS_PERSONAL_MACHINE/g" "$TEMPLATE" > "$OUTPUT"

echo "✅ Generated mcp.json"

# Copy to Claude Code config if it exists
CLAUDE_CONFIG_DIR="$HOME/.config/claude-cli-nodejs"
if [[ -d "$CLAUDE_CONFIG_DIR" ]]; then
    cp "$OUTPUT" "$CLAUDE_CONFIG_DIR/mcp.json"
    echo "✅ Copied to Claude Code config"
fi