#!/bin/bash
# Configure act caching for faster GitHub Actions testing
# Prevents re-downloading tools like Python, Node.js, etc.

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

configure_act_cache() {
    echo "Configuring act caching for faster tool downloads..."
    
    # Create cache directories
    mkdir -p ~/.cache/act/actions ~/.cache/act/tools
    
    echo -e "${GREEN}✓ act cache directories created${NC}"
    echo -e "${BLUE}Cache location: ~/.cache/act${NC}"
    echo -e "${BLUE}Actions cache: ~/.cache/act/actions${NC}"
    echo -e "${BLUE}Tools cache: ~/.cache/act/tools${NC}"
    
    # Note: Configuration is managed via dotfiles .config/act/actrc
    echo -e "${YELLOW}Note: act configuration is managed via dotfiles in .config/act/actrc${NC}"
    echo -e "${YELLOW}Actions and tools will be cached on first use${NC}"
    echo -e "${YELLOW}Common actions like setup-python, setup-node will be downloaded once${NC}"
    
    return 0
}

# Create cache warming function for common actions
warm_act_cache() {
    echo "Warming act cache with common actions..."
    
    # Only warm cache if we have a .github/workflows directory
    if [[ -d ".github/workflows" ]]; then
        echo "Found workflows, running dry-run to warm cache..."
        if command -v gh &> /dev/null && gh extension list | grep -q "nektos/gh-act"; then
            # Run a dry-run to cache actions without executing
            gh act --dryrun &>/dev/null || true
            echo -e "${GREEN}✓ Cache warmed with workflow actions${NC}"
        fi
    else
        echo -e "${YELLOW}No workflows found, cache will be populated on first use${NC}"
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_act_cache
    warm_act_cache
fi
