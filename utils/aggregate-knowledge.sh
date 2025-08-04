#!/bin/bash
# Aggregate knowledge files for GitHub Action context injection
# This script provides the same ~30k tokens of context that local Claude Code gets
# via --add-dir knowledge flag
#
# Usage: ./aggregate-knowledge.sh > knowledge-context.md
#
# Principle: systems-stewardship - Single source of truth for knowledge aggregation
# Principle: ai-provider-agnosticism - Works across different AI providers

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
KNOWLEDGE_DIR="$DOTFILES_DIR/knowledge"

# Check if knowledge directory exists
if [[ ! -d "$KNOWLEDGE_DIR" ]]; then
    echo "Error: Knowledge directory not found at: $KNOWLEDGE_DIR" >&2
    exit 1
fi

echo "# Knowledge Base Context"
echo ""
echo "This context is automatically generated from the knowledge/ directory to provide"
echo "the same context that local Claude Code receives via the --add-dir flag."
echo ""
echo "Generated at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Process the main AI index file first
if [[ -f "$KNOWLEDGE_DIR/ai-index.md" ]]; then
    echo "## AI Index"
    echo ""
    cat "$KNOWLEDGE_DIR/ai-index.md"
    echo ""
fi

# Process throughput definition (the north star)
if [[ -f "$KNOWLEDGE_DIR/throughput-definition.md" ]]; then
    echo "## Throughput Definition"
    echo ""
    cat "$KNOWLEDGE_DIR/throughput-definition.md"
    echo ""
fi

# Process all principle files
echo "## Core Principles"
echo ""
if [[ -d "$KNOWLEDGE_DIR/principles" ]]; then
    # Process README first
    if [[ -f "$KNOWLEDGE_DIR/principles/README.md" ]]; then
        echo "### Principles Overview"
        echo ""
        cat "$KNOWLEDGE_DIR/principles/README.md"
        echo ""
    fi
    
    # Process individual principles (sorted for consistency)
    for principle_file in "$KNOWLEDGE_DIR/principles"/*.md; do
        if [[ -f "$principle_file" && "$(basename "$principle_file")" != "README.md" ]]; then
            principle_name=$(basename "$principle_file" .md)
            echo "### Principle: $principle_name"
            echo ""
            cat "$principle_file"
            echo ""
        fi
    done
fi

# Process all procedure files
echo "## Procedures"
echo ""
if [[ -d "$KNOWLEDGE_DIR/procedures" ]]; then
    # Process README first
    if [[ -f "$KNOWLEDGE_DIR/procedures/README.md" ]]; then
        echo "### Procedures Overview"
        echo ""
        cat "$KNOWLEDGE_DIR/procedures/README.md"
        echo ""
    fi
    
    # Process individual procedures (sorted for consistency)
    for procedure_file in "$KNOWLEDGE_DIR/procedures"/*.md; do
        if [[ -f "$procedure_file" && "$(basename "$procedure_file")" != "README.md" ]]; then
            procedure_name=$(basename "$procedure_file" .md)
            echo "### Procedure: $procedure_name"
            echo ""
            cat "$procedure_file"
            echo ""
        fi
    done
fi

# Process personalities for consultation
echo "## Personalities"
echo ""
if [[ -d "$KNOWLEDGE_DIR/personalities" ]]; then
    # Process README first
    if [[ -f "$KNOWLEDGE_DIR/personalities/README.md" ]]; then
        echo "### Personalities Overview"
        echo ""
        cat "$KNOWLEDGE_DIR/personalities/README.md"
        echo ""
    fi
    
    # Process individual personalities
    for personality_file in "$KNOWLEDGE_DIR/personalities"/*.md; do
        if [[ -f "$personality_file" && "$(basename "$personality_file")" != "README.md" ]]; then
            personality_name=$(basename "$personality_file" .md)
            echo "### Personality: $personality_name"
            echo ""
            cat "$personality_file"
            echo ""
        fi
    done
fi

# Process tools directory if it exists
if [[ -d "$KNOWLEDGE_DIR/tools" ]]; then
    echo "## Tools"
    echo ""
    for tool_file in "$KNOWLEDGE_DIR/tools"/*.md; do
        if [[ -f "$tool_file" ]]; then
            tool_name=$(basename "$tool_file" .md)
            echo "### Tool: $tool_name"
            echo ""
            cat "$tool_file"
            echo ""
        fi
    done
fi

echo "---"
echo ""
echo "**End of Knowledge Base Context**"
echo ""
echo "This aggregated context provides the same foundational knowledge that local"
echo "Claude Code receives automatically. Use this context to understand:"
echo "- Development principles and patterns"
echo "- Git workflow procedures"
echo "- Code conventions and standards"
echo "- MCP tool usage guidelines"
echo "- Troubleshooting procedures"