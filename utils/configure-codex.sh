#!/bin/bash

# =========================================================
# CODEX CONFIGURATION AND KNOWLEDGE SETUP
# =========================================================
# PURPOSE: Install (if needed) and configure Codex with knowledge base
# Installation is trivial (npm install), configuration is interesting
# =========================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
KNOWLEDGE_DIR="$DOTFILES_DIR/knowledge"
UTILS_DIR="$DOTFILES_DIR/utils"
CODEX_DIR="$HOME/.codex"

echo -e "${BLUE}=== Codex Configuration ===${NC}"
echo ""

# Step 0: Install Codex if needed (trivial one-liner)
if ! command -v codex &> /dev/null; then
    echo "Installing OpenAI Codex CLI..."
    npm install -g @openai/codex || {
        echo -e "${RED}Failed to install Codex. Please install Node.js/npm first.${NC}"
        exit 1
    }
fi
echo -e "${GREEN}✓ Codex CLI is available${NC}"

# Step 1: Check prerequisites
echo -e "${BLUE}Step 1: Checking knowledge prerequisites...${NC}"

if [[ ! -d "$KNOWLEDGE_DIR" ]]; then
    echo -e "${RED}❌ Knowledge directory not found at: $KNOWLEDGE_DIR${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Knowledge directory found${NC}"

if [[ ! -x "$UTILS_DIR/generate-codex-knowledge.sh" ]]; then
    echo -e "${YELLOW}⚠ Making generate-codex-knowledge.sh executable...${NC}"
    chmod +x "$UTILS_DIR/generate-codex-knowledge.sh"
fi
echo -e "${GREEN}✓ Generator script ready${NC}"

# Step 2: Create .codex directory
echo ""
echo -e "${BLUE}Step 2: Setting up Codex directory...${NC}"
mkdir -p "$CODEX_DIR"
echo -e "${GREEN}✓ Created ~/.codex directory${NC}"

# Step 3: Copy config.toml to user's .codex directory
echo ""
echo -e "${BLUE}Step 3: Setting up Codex configuration...${NC}"
SOURCE_CONFIG="$DOTFILES_DIR/.codex/config.toml"
if [[ -f "$SOURCE_CONFIG" ]]; then
    cp "$SOURCE_CONFIG" "$CODEX_DIR/config.toml"
    echo -e "${GREEN}✓ Copied config.toml to ~/.codex/${NC}"
else
    echo -e "${YELLOW}⚠ No config.toml found in dotfiles, using Codex defaults${NC}"
fi

# Step 4: Generate AGENTS.md
echo ""
echo -e "${BLUE}Step 4: Generating AGENTS.md from knowledge base...${NC}"
if "$UTILS_DIR/generate-codex-knowledge.sh"; then
    echo -e "${GREEN}✓ AGENTS.md generated successfully${NC}"
else
    echo -e "${RED}❌ Failed to generate AGENTS.md${NC}"
    exit 1
fi

# Step 5: Create update hook
echo ""
echo -e "${BLUE}Step 5: Creating update mechanism...${NC}"

# Create a git hook to regenerate on knowledge changes (optional)
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    HOOKS_DIR="$DOTFILES_DIR/.git/hooks"
    HOOK_FILE="$HOOKS_DIR/post-commit"
    
    mkdir -p "$HOOKS_DIR"
    
    # Create or append to post-commit hook
    if [[ ! -f "$HOOK_FILE" ]]; then
        cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Auto-update Codex AGENTS.md when knowledge changes

# Check if any knowledge files were changed
if git diff --cached --name-only | grep -q "^knowledge/"; then
    echo "Knowledge files changed, updating Codex AGENTS.md..."
    if [[ -x "$DOTFILES_DIR/utils/generate-codex-knowledge.sh" ]]; then
        "$DOTFILES_DIR/utils/generate-codex-knowledge.sh" > /dev/null 2>&1
    fi
fi
EOF
        chmod +x "$HOOK_FILE"
        echo -e "${GREEN}✓ Created git post-commit hook for auto-updates${NC}"
    else
        echo -e "${YELLOW}ℹ Post-commit hook already exists, skipping${NC}"
    fi
fi

# Step 6: Create convenience script
echo ""
echo -e "${BLUE}Step 6: Creating convenience commands...${NC}"

# Create a project AGENTS.md template if in a git repo
if [[ -d ".git" ]] && [[ "$PWD" != "$DOTFILES_DIR" ]]; then
    if [[ ! -f "AGENTS.md" ]]; then
        cat > "AGENTS.md" << 'EOF'
# Project-Specific Agent Instructions

This file provides project-specific context to Codex.
It supplements the global knowledge from ~/.codex/AGENTS.md

## Project Overview

[Add project description here]

## Key Conventions

[Add project conventions here]

## Development Workflow

[Add workflow notes here]

---
Note: Global knowledge is automatically loaded from ~/.codex/AGENTS.md
EOF
        echo -e "${GREEN}✓ Created project AGENTS.md template${NC}"
    else
        echo -e "${YELLOW}ℹ Project AGENTS.md already exists${NC}"
    fi
fi

# Step 7: Summary
echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${BLUE}📚 Knowledge Integration Summary:${NC}"
echo -e "  • Global knowledge: ~/.codex/AGENTS.md"
echo -e "  • Source: $KNOWLEDGE_DIR"
echo -e "  • Update command: codex-update-knowledge"
echo ""
echo -e "${BLUE}📝 How Codex Uses This:${NC}"
echo -e "  1. Global: ~/.codex/AGENTS.md (your dotfiles knowledge)"
echo -e "  2. Project: ./AGENTS.md at repo root (if exists)"
echo -e "  3. Local: ./AGENTS.md in current dir (if exists)"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "  • Run 'codex-update-knowledge' after changing knowledge files"
echo -e "  • Create project-specific AGENTS.md files for context"
echo -e "  • Codex will merge all AGENTS.md files automatically"
echo ""
echo -e "${GREEN}Codex now has full access to your knowledge base!${NC}"