#!/bin/bash
# Aggregate knowledge base for GitHub Actions
# This script reads ALL knowledge files (matching Claude Code's behavior)
# and outputs them as a single text block for injection into Claude's prompt
# Principle: systems-stewardship

set -euo pipefail

# Get the repository root (two levels up from .github/scripts)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"

# Start with a header
echo "# Knowledge Base Context"
echo ""
echo "This context is automatically injected to provide Claude with understanding of:"
echo "- Core development principles and procedures"
echo "- Personality models for retrospectives"
echo "- System architecture patterns and tools"
echo "- The North Star throughput definition"
echo ""

# Note: CLAUDE.md is not included here as it's a user-specific file
# that lives in ~/.claude/CLAUDE.md (not in the repository).
# GitHub Actions only has access to committed repository files.

# Process all .md files in knowledge/ recursively to match Claude Code behavior
# This ensures GitHub Actions has the exact same context as local development
process_directory() {
    local dir="$1"
    local relative_path="${dir#$KNOWLEDGE_DIR}"
    relative_path="${relative_path#/}"  # Remove leading slash if present
    
    # Process files in current directory first
    for file in "$dir"/*.md; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file" .md)
            
            # Skip README files in subdirectories (but include the main one)
            if [[ "$filename" == "README" && "$relative_path" != "" ]]; then
                continue
            fi
            
            # Create section header based on location
            if [[ "$relative_path" == "" ]]; then
                # Root knowledge files
                title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo "# $title"
            elif [[ "$relative_path" == "principles" ]]; then
                title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo "## Principle: $title"
            elif [[ "$relative_path" == "procedures" ]]; then
                title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo "## Procedure: $title"
            elif [[ "$relative_path" == "personalities" ]]; then
                title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo "## Personality: $title"
            elif [[ "$relative_path" == "tools" ]]; then
                title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo "## Tool: $title"
            else
                # Other directories
                title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
                echo "## $relative_path: $title"
            fi
            
            echo ""
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done
    
    # Process subdirectories
    for subdir in "$dir"/*; do
        if [[ -d "$subdir" ]]; then
            dirname=$(basename "$subdir")
            # Add section header for new directory
            if [[ "$relative_path" == "" ]]; then
                echo "# $(echo "$dirname" | sed 's/\b\(.\)/\u\1/g')"
                echo ""
            fi
            process_directory "$subdir"
        fi
    done
}

# Process the entire knowledge directory
if [[ -d "$KNOWLEDGE_DIR" ]]; then
    process_directory "$KNOWLEDGE_DIR"
else
    echo "Knowledge directory not found at: $KNOWLEDGE_DIR"
    echo ""
fi

# Add a footer note
echo ""
echo "# Context Note"
echo ""
echo "This knowledge base was automatically aggregated for this GitHub Action workflow."
echo "Follow these principles and procedures to maintain consistency with the codebase patterns."
echo "Reference: Principles are in knowledge/principles/, Procedures are in knowledge/procedures/"