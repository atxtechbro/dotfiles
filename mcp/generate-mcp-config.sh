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
IS_WORK_MACHINE="${WORK_MACHINE:-false}"

echo "🔧 Generating mcp.json from template..."
echo "📍 Machine type: $([ "$IS_WORK_MACHINE" = "true" ] && echo "work" || echo "personal")"

if [ "$IS_WORK_MACHINE" = "true" ]; then
    # Include work-only servers - remove the conditional markers
    sed -e '/{{#if WORK_MACHINE}}/d' \
        -e '/{{\/if}}/d' \
        "$TEMPLATE" > "$OUTPUT"
else
    # Exclude work-only servers - remove everything between conditionals
    sed -e '/{{#if WORK_MACHINE}}/,/{{\/if}}/d' \
        "$TEMPLATE" > "$OUTPUT"
fi

echo "✅ Generated mcp.json"

# Copy to Claude Code config if it exists
CLAUDE_CONFIG_DIR="$HOME/.config/claude-cli-nodejs"
if [[ -d "$CLAUDE_CONFIG_DIR" ]]; then
    cp "$OUTPUT" "$CLAUDE_CONFIG_DIR/mcp.json"
    echo "✅ Copied to Claude Code config"
fi