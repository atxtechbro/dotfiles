#!/bin/bash
# Aggregate knowledge base for GitHub Actions
# This script reads all knowledge files and outputs them as a single text block
# for injection into Claude's prompt in GitHub Actions workflows
# Principle: systems-stewardship

set -euo pipefail

# Get the repository root (two levels up from .github/scripts)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"

# Function to output a section with clear markers
output_section() {
    local title="$1"
    local content="$2"
    
    echo "## $title"
    echo ""
    echo "$content"
    echo ""
}

# Start with a header
echo "# Knowledge Base Context"
echo ""
echo "This context is automatically injected to provide Claude with understanding of:"
echo "- Core development principles"
echo "- Established procedures and workflows"
echo "- Git conventions and standards"
echo "- System architecture patterns"
echo ""

# Note: CLAUDE.md is not included here as it's a user-specific file
# that lives in ~/.claude/CLAUDE.md (not in the repository).
# GitHub Actions only has access to committed repository files.

# Read all principle files
if [[ -d "$KNOWLEDGE_DIR/principles" ]]; then
    echo "# Core Principles"
    echo ""
    
    found_principles=0
    for file in "$KNOWLEDGE_DIR/principles"/*.md; do
        if [[ -f "$file" ]]; then
            found_principles=1
            filename=$(basename "$file" .md)
            # Convert filename to title case (e.g., tracer-bullets -> Tracer Bullets)
            title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
            
            echo "## $title"
            echo ""
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done
    
    if [[ $found_principles -eq 0 ]]; then
        echo "No principle files found in knowledge/principles/"
        echo ""
    fi
fi

# Read all procedure files
if [[ -d "$KNOWLEDGE_DIR/procedures" ]]; then
    echo "# Established Procedures"
    echo ""
    
    found_procedures=0
    for file in "$KNOWLEDGE_DIR/procedures"/*.md; do
        if [[ -f "$file" ]]; then
            found_procedures=1
            filename=$(basename "$file" .md)
            # Convert filename to title case
            title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
            
            echo "## $title"
            echo ""
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done
    
    if [[ $found_procedures -eq 0 ]]; then
        echo "No procedure files found in knowledge/procedures/"
        echo ""
    fi
fi

# Add a footer note
echo ""
echo "# Context Note"
echo ""
echo "This knowledge base was automatically aggregated for this GitHub Action workflow."
echo "Follow these principles and procedures to maintain consistency with the codebase patterns."
echo "Reference: Principles are in knowledge/principles/, Procedures are in knowledge/procedures/"