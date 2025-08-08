#!/bin/bash

# =========================================================
# CODEX AGENTS.md GENERATOR
# =========================================================
# PURPOSE: Aggregate knowledge base into Codex AGENTS.md format
# This ensures Codex has access to all dotfiles knowledge
# regardless of where it's started from
# =========================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
KNOWLEDGE_DIR="$DOTFILES_DIR/knowledge"
CODEX_DIR="$HOME/.codex"

# Create .codex directory if it doesn't exist
mkdir -p "$CODEX_DIR"

generate_agents_md() {
    local output_file="$1"
    
    echo -e "${BLUE}📚 Generating AGENTS.md from knowledge base...${NC}"
    
    # Start with header
    cat > "$output_file" << 'EOF'
# Codex Agent Instructions and Knowledge Base

This file is auto-generated from the dotfiles knowledge base.
It provides Codex with comprehensive project context and principles.

---

EOF
    
    # Add principles section
    if [[ -d "$KNOWLEDGE_DIR/principles" ]]; then
        echo -e "${YELLOW}  Adding principles...${NC}"
        echo "## Core Principles" >> "$output_file"
        echo "" >> "$output_file"
        
        for principle_file in "$KNOWLEDGE_DIR/principles"/*.md; do
            if [[ -f "$principle_file" ]]; then
                local principle_name=$(basename "$principle_file" .md)
                echo "### $(echo $principle_name | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')" >> "$output_file"
                echo "" >> "$output_file"
                cat "$principle_file" >> "$output_file"
                echo "" >> "$output_file"
                echo "---" >> "$output_file"
                echo "" >> "$output_file"
            fi
        done
    fi
    
    # Add procedures section
    if [[ -d "$KNOWLEDGE_DIR/procedures" ]]; then
        echo -e "${YELLOW}  Adding procedures...${NC}"
        echo "## Standard Procedures" >> "$output_file"
        echo "" >> "$output_file"
        
        for procedure_file in "$KNOWLEDGE_DIR/procedures"/*.md; do
            if [[ -f "$procedure_file" ]]; then
                local procedure_name=$(basename "$procedure_file" .md)
                # Skip codex-specific files to avoid recursion
                if [[ "$procedure_name" != "codex-integration" ]]; then
                    echo "### $(echo $procedure_name | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')" >> "$output_file"
                    echo "" >> "$output_file"
                    cat "$procedure_file" >> "$output_file"
                    echo "" >> "$output_file"
                    echo "---" >> "$output_file"
                    echo "" >> "$output_file"
                fi
            fi
        done
    fi
    
    # Add patterns section
    if [[ -d "$KNOWLEDGE_DIR/patterns" ]]; then
        echo -e "${YELLOW}  Adding patterns...${NC}"
        echo "## Design Patterns" >> "$output_file"
        echo "" >> "$output_file"
        
        for pattern_file in "$KNOWLEDGE_DIR/patterns"/*.md; do
            if [[ -f "$pattern_file" ]]; then
                local pattern_name=$(basename "$pattern_file" .md)
                echo "### $(echo $pattern_name | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')" >> "$output_file"
                echo "" >> "$output_file"
                cat "$pattern_file" >> "$output_file"
                echo "" >> "$output_file"
                echo "---" >> "$output_file"
                echo "" >> "$output_file"
            fi
        done
    fi
    
    # Add context section
    if [[ -d "$KNOWLEDGE_DIR/context" ]]; then
        echo -e "${YELLOW}  Adding context...${NC}"
        echo "## Project Context" >> "$output_file"
        echo "" >> "$output_file"
        
        for context_file in "$KNOWLEDGE_DIR/context"/*.md; do
            if [[ -f "$context_file" ]]; then
                local context_name=$(basename "$context_file" .md)
                echo "### $(echo $context_name | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')" >> "$output_file"
                echo "" >> "$output_file"
                cat "$context_file" >> "$output_file"
                echo "" >> "$output_file"
                echo "---" >> "$output_file"
                echo "" >> "$output_file"
            fi
        done
    fi
    
    # Add footer with metadata
    cat >> "$output_file" << EOF

---

## Metadata

- Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
- Source: $KNOWLEDGE_DIR
- Dotfiles: $DOTFILES_DIR
- Purpose: Provide Codex with comprehensive project knowledge

## Additional Resources

- Local CLAUDE.md files for project-specific instructions
- Repository AGENTS.md files for project-specific context
- Working directory AGENTS.md for feature-specific guidance

EOF
    
    echo -e "${GREEN}✓ AGENTS.md generated successfully${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}=== Codex Knowledge Integration ===${NC}"
    echo ""
    
    # Check if knowledge directory exists
    if [[ ! -d "$KNOWLEDGE_DIR" ]]; then
        echo -e "${YELLOW}⚠ Knowledge directory not found at: $KNOWLEDGE_DIR${NC}"
        echo "Creating empty AGENTS.md..."
        cat > "$CODEX_DIR/AGENTS.md" << 'EOF'
# Codex Agent Instructions

No knowledge base found. Please ensure the dotfiles knowledge directory exists.

EOF
        exit 0
    fi
    
    # Generate global AGENTS.md
    generate_agents_md "$CODEX_DIR/AGENTS.md"
    
    # Show file stats
    local line_count=$(wc -l < "$CODEX_DIR/AGENTS.md")
    local size=$(du -h "$CODEX_DIR/AGENTS.md" | cut -f1)
    
    echo ""
    echo -e "${BLUE}📊 Statistics:${NC}"
    echo -e "  Location: $CODEX_DIR/AGENTS.md"
    echo -e "  Lines: $line_count"
    echo -e "  Size: $size"
    
    echo ""
    echo -e "${GREEN}=== Setup Complete ===${NC}"
    echo "Codex will now have access to your knowledge base from any directory!"
    echo ""
    echo "The knowledge is available in this hierarchy:"
    echo "1. ~/.codex/AGENTS.md (global - your dotfiles knowledge)"
    echo "2. ./AGENTS.md (project root - if exists)"
    echo "3. ./AGENTS.md (current dir - if exists)"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi