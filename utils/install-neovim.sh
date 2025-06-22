#!/bin/bash
# Neovim Installation Utility
# Automated installation following the spilled coffee principle

# Source common logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logging.sh"

install_neovim() {
    log_info "Setting up Neovim..."
    
    # Check if Neovim is already installed
    if command -v nvim &> /dev/null; then
        CURRENT_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_success "Neovim is already installed (version $CURRENT_VERSION)"
        return 0
    fi
    
    log_info "Installing Neovim..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation via Homebrew
        if command -v brew &> /dev/null; then
            log_info "Installing Neovim via Homebrew..."
            if brew install neovim; then
                log_success "Neovim installed successfully via Homebrew"
            else
                log_error "Failed to install Neovim via Homebrew"
                return 1
            fi
        else
            log_error "Homebrew not found. Please install Homebrew first."
            return 1
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        if command -v apt &> /dev/null; then
            # Ubuntu/Debian - use PPA for latest version
            log_info "Installing Neovim via apt (using unstable PPA for latest version)..."
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt-get update
            sudo apt-get install -y neovim
            
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            log_info "Installing Neovim via pacman..."
            sudo pacman -S --noconfirm neovim
            
        elif command -v dnf &> /dev/null; then
            # Fedora/RHEL
            log_info "Installing Neovim via dnf..."
            sudo dnf install -y neovim
            
        else
            # Fallback: build from source
            log_warning "No package manager found. Building Neovim from source..."
            install_neovim_from_source
            return $?
        fi
        
        if command -v nvim &> /dev/null; then
            log_success "Neovim installed successfully"
        else
            log_warning "Package installation completed but nvim command not found. Trying source build..."
            install_neovim_from_source
            return $?
        fi
        
    else
        log_error "Unsupported OS: $OSTYPE"
        return 1
    fi
    
    # Verify installation
    if command -v nvim &> /dev/null; then
        INSTALLED_VERSION=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_success "Neovim installation verified (version $INSTALLED_VERSION)"
        return 0
    else
        log_error "Neovim installation failed"
        return 1
    fi
}

install_neovim_from_source() {
    log_info "Building Neovim from source..."
    
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
        log_error "Failed to create temporary directory"
        return 1
    }
    
    # Clone and build Neovim
    if git clone https://github.com/neovim/neovim.git; then
        cd neovim || return 1
        
        log_info "Building Neovim (this may take a few minutes)..."
        if make CMAKE_BUILD_TYPE=RelWithDebInfo; then
            log_info "Installing Neovim..."
            if sudo make install; then
                log_success "Neovim built and installed from source"
                cd / && rm -rf "$temp_dir"
                return 0
            fi
        fi
    fi
    
    log_error "Failed to build Neovim from source"
    cd / && rm -rf "$temp_dir"
    return 1
}

setup_neovim_config() {
    if ! command -v nvim &> /dev/null; then
        return 1
    fi
    
    log_info "Setting up Neovim configuration..."
    
    # Create config directory
    mkdir -p ~/.config
    
    # Link Neovim configuration if dotfiles are available
    if [[ -d "$HOME/ppv/pillars/dotfiles/nvim" ]]; then
        rm -rf ~/.config/nvim
        ln -sfn "$HOME/ppv/pillars/dotfiles/nvim" ~/.config/nvim
        log_success "Neovim configuration linked"
    else
        log_warning "Dotfiles nvim configuration not found. Skipping config setup."
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
