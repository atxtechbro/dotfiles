#!/bin/bash
# Generate Claude commands using Python prompt orchestrator
# Principle: systems-stewardship

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$DOTFILES_DIR/.claude/command-templates"
COMMANDS_DIR="$DOTFILES_DIR/.claude/commands"
PROMPT_ORCHESTRATOR="$SCRIPT_DIR/prompt_orchestrator.py"

# Create directories if they don't exist
mkdir -p "$TEMPLATES_DIR" "$COMMANDS_DIR"

# Check if prompt orchestrator exists
if [[ ! -x "$PROMPT_ORCHESTRATOR" ]]; then
    echo "Error: prompt_orchestrator.py not found or not executable at: $PROMPT_ORCHESTRATOR"
    exit 1
fi

echo "Generating Claude commands from templates..."

# Process all template files
for template in "$TEMPLATES_DIR"/*.md; do
    if [[ -f "$template" ]]; then
        filename=$(basename "$template")
        output="$COMMANDS_DIR/$filename"
        
        echo "  Processing: $filename"
        # Use Python orchestrator with knowledge base
        # Replace {{VAR:ARGUMENTS}} with $ARGUMENTS for Claude commands
        "$PROMPT_ORCHESTRATOR" "$template" \
            -o "$output" \
            -v ARGUMENTS='$ARGUMENTS' \
            -k "$DOTFILES_DIR/knowledge"
    fi
done

echo "Claude commands generated successfully!"
echo "Commands available at: $COMMANDS_DIR"