#!/bin/bash
# AI Provider Agnostic Setup Utility
# Links all AI provider context files to central AI-RULES.md

setup_ai_provider_agnostic() {
    local dot_den="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
    
    # Define AI provider files to link
    local ai_providers=(
        "AmazonQ.md"
        "CLAUDE.md" 
        ".cursorrules"
        "CODEX.md"
    )
    
    echo "Setting up AI provider agnostic context..."
    
    # Check if AI-RULES.md exists
    if [[ ! -f "$dot_den/AI-RULES.md" ]]; then
        echo -e "${YELLOW}⚠ AI-RULES.md not found, skipping AI provider setup${NC}"
        return 0
    fi
    
    for provider_file in "${ai_providers[@]}"; do
        local provider_path="$dot_den/$provider_file"
        
        # Only create symlink if provider file doesn't already exist as symlink
        if [[ ! -L "$provider_path" ]]; then
            # Remove existing file if it exists and isn't a symlink
            [[ -f "$provider_path" ]] && rm "$provider_path"
            
            # Create symlink to AI-RULES.md (relative path for portability)
            cd "$dot_den" && ln -sf AI-RULES.md "$provider_file"
            echo -e "${GREEN}✓ Linked $provider_file -> AI-RULES.md${NC}"
        elif [[ -L "$provider_path" ]]; then
            echo -e "${BLUE}✓ $provider_file already linked${NC}"
        fi
    done
    
    echo -e "${GREEN}✓ AI provider agnostic setup complete${NC}"
}

# Allow script to be sourced or run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Running directly - set up colors and call function
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    
    setup_ai_provider_agnostic
fi
