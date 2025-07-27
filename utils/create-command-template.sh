#!/bin/bash
# Create a new command template with proper structure
# This enforces the generation-time validation pattern from the start

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <command-name> [param1] [param2] ..."
    echo "Example: $0 deploy-app ENVIRONMENT APP_NAME"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$DOTFILES_DIR/commands/templates"

command_name="$1"
shift
params=("$@")

template_file="$TEMPLATES_DIR/${command_name}.md"

if [ -f "$template_file" ]; then
    echo "Error: Template $template_file already exists"
    exit 1
fi

# Create the template with clear structure
cat > "$template_file" << 'TEMPLATE'
# COMMAND_NAME Command

DESCRIPTION_PLACEHOLDER

## Core Logic
INJECT_PRINCIPLES_IF_NEEDED

MAIN_INSTRUCTIONS_HERE

TEMPLATE

# Replace placeholders
sed -i "s/COMMAND_NAME/${command_name}/g" "$template_file"

# Add parameter placeholders
if [ ${#params[@]} -gt 0 ]; then
    echo "" >> "$template_file"
    echo "## Parameters" >> "$template_file"
    for param in "${params[@]}"; do
        echo "- {{ $param }}" >> "$template_file"
    done
fi

# Now update generate-commands.sh with validation stub
generator="$DOTFILES_DIR/utils/generate-commands.sh"

# Find the injection point and add stub
if grep -q "# ADD NEW COMMAND VALIDATIONS HERE" "$generator"; then
    # Create a backup
    cp "$generator" "${generator}.bak"
    
    # Insert the new validation stub
    awk -v cmd="$command_name" -v params="${params[*]}" '
    /# ADD NEW COMMAND VALIDATIONS HERE/ {
        print
        print "                        " cmd ")"
        print "                            cat >> \"$output.tmp\" << '\''EOF'\''"
        print "# TODO: Add validation for " cmd
        if (params != "") {
            split(params, p, " ")
            for (i in p) {
                print "# if [ -z \"$" p[i] "\" ]; then"
                print "#     echo \"Error: " p[i] " is required\""
                print "#     exit 1"
                print "# fi"
            }
        }
        print ""
        print "EOF"
        print "                            ;;"
        next
    }
    { print }
    ' "$generator.bak" > "$generator"
    
    rm "$generator.bak"
fi

echo "✅ Created template: $template_file"
echo "✅ Added validation stub to generate-commands.sh"
echo ""
echo "Next steps:"
echo "1. Edit $template_file to add your command logic"
echo "2. Check if housekeeping already handles your validation needs:"
echo "   - Issue commands: auto-validates issue exists, git state, auth"
echo "   - PR commands: auto-validates PR exists, git state, auth"
echo "   - See utils/command-housekeeping.sh for what's automatic"
echo "3. Add only command-specific validation to generate-commands.sh"
echo "4. Run ./utils/generate-commands.sh to test"
echo ""
echo "Available after housekeeping:"
echo "- \$ISSUE_STATE, \$ISSUE_TITLE, \$ISSUE_LABELS (issue commands)"
echo "- \$PR_STATE, \$PR_TITLE, \$PR_BASE_BRANCH (PR commands)"
echo "- \$WORKTREE_PATH (suggested isolation path)"
echo ""
echo "Remember: Validation goes in the generator, NOT the template!"