#!/bin/bash
# Generate Claude commands using Python prompt orchestrator
# Principle: systems-stewardship

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$DOTFILES_DIR/.claude/command-templates"
COMMANDS_DIR="$HOME/.claude/commands"
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
        command_name="${filename%.md}"
        
        echo "  Processing: $filename"
        
        # First, process the template
        "$PROMPT_ORCHESTRATOR" "$template" \
            -o "$output" \
            -v ISSUE_NUMBER='$ISSUE_NUMBER' \
            -k "$DOTFILES_DIR/knowledge"
        
        # Generate session ID for this command execution
        # Then prepend logging to the generated file
        cat > "$output.tmp" << 'EOF'
<!-- SLASH COMMAND USAGE LOGGING -->
<!-- Logs to ~/claude-slash-commands.log -->
!SESSION_ID="$(date '+%Y%m%d-%H%M%S')-COMMAND_NAME-$ARGUMENTS"
!echo "$(date '+%Y-%m-%d %H:%M:%S') | SESSION_START | $SESSION_ID | COMMAND_NAME | $ARGUMENTS" >> ~/claude-slash-commands.log

<!-- Log each tool usage during this session -->
<!-- Claude will inject: !echo "$(date '+%Y-%m-%d %H:%M:%S') | TOOL_USE | $SESSION_ID | TOOL_NAME" >> ~/claude-slash-commands.log -->

EOF
        
        # Replace COMMAND_NAME with actual command name
        sed -i "s/COMMAND_NAME/$command_name/g" "$output.tmp"
        
        # Append the original content
        cat "$output" >> "$output.tmp"
        
        # Replace original with logged version
        mv "$output.tmp" "$output"
    fi
done

echo "Claude commands generated successfully!"
echo "Commands available at: $COMMANDS_DIR"