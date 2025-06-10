#!/bin/bash
# Neovim Installation Utility
# Automated installation following the spilled coffee principle

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_neovim() {
    echo "Setting up Neovim..."
    
    # Check if Neovim is already installed
    if command -v nvim &> /dev/null; then
        CURRENT_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
        echo -e "${GREEN}✓ Neovim is already installed (version $CURRENT_VERSION)${NC}"
        return 0
    fi
    
    echo "Installing Neovim..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation via Homebrew
        if command -v brew &> /dev/null; then
            echo "Installing Neovim via Homebrew..."
            if brew install neovim; then
                echo -e "${GREEN}✓ Neovim installed successfully via Homebrew${NC}"
            else
                echo -e "${RED}Failed to install Neovim via Homebrew${NC}"
                return 1
            fi
        else
            echo -e "${RED}Homebrew not found. Please install Homebrew first.${NC}"
            return 1
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        if command -v apt &> /dev/null; then
            # Ubuntu/Debian - use PPA for latest version
            echo "Installing Neovim via apt (using unstable PPA for latest version)..."
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt-get update
            sudo apt-get install -y neovim
            
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            echo "Installing Neovim via pacman..."
            sudo pacman -S --noconfirm neovim
            
        elif command -v dnf &> /dev/null; then
            # Fedora/RHEL
            echo "Installing Neovim via dnf..."
            sudo dnf install -y neovim
            
        else
            # Fallback: build from source
            echo "No package manager found. Building Neovim from source..."
            install_neovim_from_source
            return $?
        fi
        
        if command -v nvim &> /dev/null; then
            echo -e "${GREEN}✓ Neovim installed successfully${NC}"
        else
            echo -e "${YELLOW}Package installation completed but nvim command not found. Trying source build...${NC}"
            install_neovim_from_source
            return $?
        fi
        
    else
        echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
        return 1
    fi
    
    # Verify installation
    if command -v nvim &> /dev/null; then
        INSTALLED_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
        echo -e "${GREEN}✓ Neovim installation verified (version $INSTALLED_VERSION)${NC}"
        return 0
    else
        echo -e "${RED}Neovim installation failed${NC}"
        return 1
    fi
}

install_neovim_from_source() {
    echo "Building Neovim from source..."
    
    # Install build dependencies
    if command -v apt &> /dev/null; then
        sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm base-devel cmake unzip ninja curl
    elif command -v dnf &> /dev/null; then
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y ninja-build cmake unzip curl
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
        echo -e "${RED}Failed to create temporary directory${NC}"
        return 1
    }
    
    # Clone and build Neovim
    if git clone https://github.com/neovim/neovim.git; then
        cd neovim || return 1
        
        echo "Building Neovim (this may take a few minutes)..."
        if make CMAKE_BUILD_TYPE=RelWithDebInfo; then
            echo "Installing Neovim..."
            if sudo make install; then
                echo -e "${GREEN}✓ Neovim built and installed from source${NC}"
                cd / && rm -rf "$temp_dir"
                return 0
            fi
        fi
    fi
    
    echo -e "${RED}Failed to build Neovim from source${NC}"
    cd / && rm -rf "$temp_dir"
    return 1
}

setup_neovim_config() {
    if ! command -v nvim &> /dev/null; then
        return 1
    fi
    
    echo "Setting up Neovim configuration..."
    
    # Create config directory
    mkdir -p ~/.config
    
    # Link Neovim configuration if dotfiles are available
    if [[ -d "$HOME/ppv/pillars/dotfiles/nvim" ]]; then
        rm -rf ~/.config/nvim
        ln -sfn "$HOME/ppv/pillars/dotfiles/nvim" ~/.config/nvim
        echo -e "${GREEN}✓ Neovim configuration linked${NC}"
    else
        echo -e "${YELLOW}Dotfiles nvim configuration not found. Skipping config setup.${NC}"
    fi
    
    return 0
}

setup_neovim() {
    # Install Neovim
    if install_neovim; then
        # Set up configuration
        setup_neovim_config
        return 0
    else
        return 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_neovim
fi
