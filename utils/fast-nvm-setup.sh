#!/bin/bash
# Fast NVM setup with caching
# Optimizes Node.js installation by avoiding redundant operations

# Source cache utilities
source "$(dirname "${BASH_SOURCE[0]}")/cache-utils.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# NVM version to install
NVM_VERSION="v0.39.7"
NVM_DIR="$HOME/.nvm"

setup_nvm_cached() {
    # Check if NVM is already installed and cached
    if is_cached "nvm" 30; then  # Cache for 30 days
        # Source NVM if it exists
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            source "$NVM_DIR/nvm.sh"
            source "$NVM_DIR/bash_completion" 2>/dev/null || true
            
            # Quick version check
            if command -v nvm >/dev/null 2>&1; then
                local current_node=$(node -v 2>/dev/null || echo "none")
                echo -e "${GREEN}✓ NVM already installed (cached), Node.js: $current_node${NC}"
                return 0
            fi
        fi
        # If we get here, cache is invalid
        clear_cache "nvm"
    fi
    
    # Check if NVM exists but not cached
    if [[ -d "$NVM_DIR" ]] && [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        source "$NVM_DIR/bash_completion" 2>/dev/null || true
        
        if command -v nvm >/dev/null 2>&1; then
            echo "NVM found, checking Node.js version..."
            
            # Get current and latest LTS versions
            local current_version=$(node -v 2>/dev/null | sed 's/v//' || echo "0.0.0")
            local latest_lts=$(nvm version-remote --lts 2>/dev/null | sed 's/v//' || echo "unknown")
            
            if [[ "$latest_lts" != "unknown" ]]; then
                # Compare versions - only update if significantly outdated
                local current_major=$(echo "$current_version" | cut -d. -f1)
                local latest_major=$(echo "$latest_lts" | cut -d. -f1)
                
                if [[ $current_major -ge $((latest_major - 2)) ]]; then
                    # Current version is within 2 major versions, good enough
                    echo -e "${GREEN}✓ Node.js $current_version is recent enough (latest LTS: $latest_lts)${NC}"
                    mark_cached "nvm" "$current_version"
                    return 0
                else
                    echo "Node.js $current_version is outdated, updating to $latest_lts..."
                    nvm install --lts >/dev/null 2>&1
                    nvm use --lts >/dev/null 2>&1
                    nvm alias default 'lts/*' >/dev/null 2>&1
                fi
            fi
            
            local final_version=$(node -v 2>/dev/null || echo "unknown")
            mark_cached "nvm" "$final_version"
            echo -e "${GREEN}✓ NVM configured with Node.js $final_version${NC}"
            return 0
        fi
    fi
    
    # Fresh NVM installation
    echo "Installing NVM (Node Version Manager)..."
    
    # Download and install NVM
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" 2>/dev/null | bash >/dev/null 2>&1
    
    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    
    # Install latest LTS Node.js
    echo "Installing Node.js LTS..."
    nvm install --lts >/dev/null 2>&1
    nvm use --lts >/dev/null 2>&1
    nvm alias default 'lts/*' >/dev/null 2>&1
    
    local node_version=$(node -v 2>/dev/null || echo "unknown")
    mark_cached "nvm" "$node_version"
    
    echo -e "${GREEN}✓ NVM installed with Node.js $node_version${NC}"
    return 0
}

# Quick check function for other scripts
quick_nvm_check() {
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh" 2>/dev/null
        command -v node >/dev/null 2>&1
    else
        return 1
    fi
}

# Main execution if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_nvm_cached
fi

# Export functions
export -f setup_nvm_cached
export -f quick_nvm_check