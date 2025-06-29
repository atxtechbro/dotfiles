#!/bin/bash

# MCP config generator from template
# Generates config directly to all needed locations, avoiding intermediate files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_DEN="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$SCRIPT_DIR/mcp.template.json"

# Check if template exists
if [[ ! -f "$TEMPLATE" ]]; then
    echo "❌ Error: Template file not found: $TEMPLATE"
    exit 1
fi

# Check if we're on a work machine
IS_WORK_MACHINE="${WORK_MACHINE:-false}"

echo "🔧 Generating MCP configuration from template..."
echo "📍 Machine type: $([ "$IS_WORK_MACHINE" = "true" ] && echo "work" || echo "personal")"

# Function to generate config from template
generate_config() {
    local output="$1"
    if [ "$IS_WORK_MACHINE" = "true" ]; then
        # Include work-only servers - remove the conditional markers
        sed -e '/{{#if WORK_MACHINE}}/d' \
            -e '/{{\/if}}/d' \
            "$TEMPLATE" > "$output"
    else
        # Exclude work-only servers - remove everything between conditionals
        sed -e '/{{#if WORK_MACHINE}}/,/{{\/if}}/d' \
            "$TEMPLATE" > "$output"
    fi
}

# Generate to all needed locations
echo "📦 Generating configurations..."

# Amazon Q global config
mkdir -p ~/.aws/amazonq
generate_config ~/.aws/amazonq/mcp.json
echo "  ✅ Amazon Q (~/.aws/amazonq/mcp.json)"

# Claude Desktop config
mkdir -p ~/.config/claude
generate_config ~/.config/claude/claude_desktop_config.json
echo "  ✅ Claude Desktop (~/.config/claude/claude_desktop_config.json)"

# Claude Code project-level config (when working in dotfiles repo)
generate_config "$DOT_DEN/.mcp.json"
echo "  ✅ Claude Code project config ($DOT_DEN/.mcp.json)"

# Claude Code legacy config location (if directory exists)
CLAUDE_LEGACY_DIR="$HOME/.config/claude-cli-nodejs"
if [[ -d "$CLAUDE_LEGACY_DIR" ]]; then
    generate_config "$CLAUDE_LEGACY_DIR/mcp.json"
    echo "  ✅ Claude Code legacy config ($CLAUDE_LEGACY_DIR/mcp.json)"
fi

echo "✨ All MCP configurations generated successfully!"