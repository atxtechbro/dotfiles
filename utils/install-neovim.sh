#!/bin/bash
# Neovim Installation Utility
# Automated installation following the spilled coffee principle

# Source common logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logging.sh"

install_neovim() {
    log_info "Setting up nvim..."
    
    # Check if Neovim is already installed
    if command -v nvim &> /dev/null; then
        CURRENT_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_success "Already installed: $CURRENT_VERSION"
        return 0
    fi
    
    log_info "Installing nvim..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation via Homebrew
        if command -v brew &> /dev/null; then
            log_info "Using Homebrew..."
            if brew install neovim; then
                log_success "Installed via Homebrew"
            else
                log_error "Homebrew install failed"
                return 1
            fi
        else
            log_error "Homebrew not found"
            return 1
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        if command -v apt &> /dev/null; then
            # Ubuntu/Debian - use PPA for latest version
            log_info "Using apt + PPA..."
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt-get update
            sudo apt-get install -y neovim
            
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            log_info "Using pacman..."
            sudo pacman -S --noconfirm neovim
            
        elif command -v dnf &> /dev/null; then
            # Fedora/RHEL
            log_info "Using dnf..."
            sudo dnf install -y neovim
            
        else
            # Fallback: build from source
            log_warning "Building from source..."
            install_neovim_from_source
            return $?
        fi
        
        if command -v nvim &> /dev/null; then
            log_success "Installed"
        else
            log_warning "Not found, building from source..."
            install_neovim_from_source
            return $?
        fi
        
    else
        log_error "Unsupported: $OSTYPE"
        return 1
    fi
    
    # Verify installation
    if command -v nvim &> /dev/null; then
        INSTALLED_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_success "Verified: $INSTALLED_VERSION"
        return 0
    else
        log_error "Install failed"
        return 1
    fi
}

install_neovim_from_source() {
    log_info "Building from source..."
    
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
        log_error "Temp dir failed"
        return 1
    }
    
    # Clone and build Neovim
    if git clone https://github.com/neovim/neovim.git; then
        cd neovim || return 1
        
        log_info "Building (takes time)..."
        if make CMAKE_BUILD_TYPE=RelWithDebInfo; then
            log_info "Installing..."
            if sudo make install; then
                log_success "Built from source"
                cd / && rm -rf "$temp_dir"
                return 0
            fi
        fi
    fi
    
    log_error "Build failed"
    cd / && rm -rf "$temp_dir"
    return 1
}

setup_neovim_config() {
    if ! command -v nvim &> /dev/null; then
        return 1
    fi
    
    log_info "Setting up config..."
    
    # Create config directory
    mkdir -p ~/.config
    
    # Link Neovim configuration if dotfiles are available
    if [[ -d "$HOME/ppv/pillars/dotfiles/nvim" ]]; then
        rm -rf ~/.config/nvim
        ln -sfn "$HOME/ppv/pillars/dotfiles/nvim" ~/.config/nvim
        log_success "Config linked"
    else
        log_warning "nvim config not found"
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
