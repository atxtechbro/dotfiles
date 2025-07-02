#!/bin/bash
# Generate commands for AI providers using Python prompt orchestrator
# Vendor-agnostic command generation supporting multiple AI coding assistants
# Principle: systems-stewardship

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$DOTFILES_DIR/commands/templates"
PROMPT_ORCHESTRATOR="$SCRIPT_DIR/prompt_orchestrator.py"

# Provider-specific output directories
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
# Future: Add Amazon Q and other providers here

# Create directories if they don't exist
mkdir -p "$TEMPLATES_DIR" "$CLAUDE_COMMANDS_DIR"

# Check if prompt orchestrator exists
if [[ ! -x "$PROMPT_ORCHESTRATOR" ]]; then
    echo "Error: prompt_orchestrator.py not found or not executable at: $PROMPT_ORCHESTRATOR"
    exit 1
fi

echo "Generating commands from templates..."

# Process all template files
for template in "$TEMPLATES_DIR"/*.md; do
    if [[ -f "$template" ]]; then
        filename=$(basename "$template")
        command_name="${filename%.md}"
        
        echo "  Processing: $filename"
        
        # Generate for Claude Code
        if [[ -d "$HOME/.claude" ]]; then
            output="$CLAUDE_COMMANDS_DIR/$filename"
            
            # First, process the template
            "$PROMPT_ORCHESTRATOR" "$template" \
                -o "$output" \
                -v ISSUE_NUMBER='$ISSUE_NUMBER' \
                -k "$DOTFILES_DIR/knowledge"
            
            # Add Claude-specific logging
            cat > "$output.tmp" << EOF
!echo "\$(date '+%Y-%m-%d %H:%M:%S') $command_name \$ARGUMENTS" >> ~/claude-slash-commands.log

EOF
            
            # Append the original content
            cat "$output" >> "$output.tmp"
            
            # Replace original with logged version
            mv "$output.tmp" "$output"
            
            echo "    → Generated for Claude Code"
        fi
        
        # Future: Add generation for Amazon Q and other providers here
        # Each provider may have different output formats or requirements
    fi
done

echo "Commands generated successfully!"
echo "Commands available at:"
[[ -d "$CLAUDE_COMMANDS_DIR" ]] && echo "  Claude Code: $CLAUDE_COMMANDS_DIR"
# Future: Show paths for other providers