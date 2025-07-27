#!/bin/bash
# Check for validation logic in templates (anti-pattern detector)
# Principle: generation-time-validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$DOTFILES_DIR/commands/templates"

# Patterns that suggest validation in templates (anti-patterns)
VALIDATION_PATTERNS=(
    "If.*is empty"
    "If.*is not provided"
    "First.*check if"
    "Validate that"
    "respond with error"
    "STOP immediately"
    "is:.*Empty or undefined"
    "Check.*before proceeding"
)

echo "Checking for validation anti-patterns in templates..."
echo "================================================"

found_issues=0

for template in "$TEMPLATES_DIR"/*.md; do
    [[ ! -f "$template" ]] && continue
    [[ "$template" == *"README.md" ]] && continue
    [[ "$template" == *".template-example.md" ]] && continue
    
    filename=$(basename "$template")
    
    for pattern in "${VALIDATION_PATTERNS[@]}"; do
        if grep -i "$pattern" "$template" >/dev/null 2>&1; then
            echo "⚠️  $filename: Found validation pattern '$pattern'"
            echo "   Move this validation to generate-commands.sh instead!"
            found_issues=$((found_issues + 1))
        fi
    done
done

echo "================================================"

if [[ $found_issues -eq 0 ]]; then
    echo "✅ No validation anti-patterns found in templates!"
else
    echo "❌ Found $found_issues validation anti-patterns"
    echo ""
    echo "Remember: Validation in templates = token waste"
    echo "          Validation in generator = zero tokens"
    echo ""
    echo "See knowledge/principles/generation-time-validation.md"
    exit 1
fi