#!/bin/bash
# VS Code Installation Utility
# Automated installation following the spilled coffee principle

# Source common logging functions
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
source "${SCRIPT_DIR}/logging.sh"

install_vscode() {
    log_info "Setting up VS Code..."
    
    # Check if VS Code is already installed
    if command -v code &> /dev/null; then
        CURRENT_VERSION=$(code --version 2>/dev/null | head -n1)
        log_success "Already installed: $CURRENT_VERSION"
        return 0
    fi
    
    log_info "Installing VS Code..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation via Homebrew
        if command -v brew &> /dev/null; then
            log_info "Using Homebrew..."
            if brew install --cask visual-studio-code; then
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
        # Linux installation using official Microsoft repository
        if command -v apt &> /dev/null; then
            # Ubuntu/Debian/Linux Mint
            log_info "Using apt with Microsoft repository..."
            
            # Install dependencies
            sudo apt-get update
            sudo apt-get install -y wget gpg apt-transport-https
            
            # Add Microsoft GPG key
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            
            # Add VS Code repository
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
                sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
            
            # Clean up temporary GPG file
            rm -f packages.microsoft.gpg
            
            # Update and install VS Code
            sudo apt-get update
            if sudo apt-get install -y code; then
                log_success "Installed via apt"
            else
                log_error "apt install failed"
                return 1
            fi
            
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            log_info "Using pacman..."
            if sudo pacman -S --noconfirm code; then
                log_success "Installed via pacman"
            else
                log_error "pacman install failed"
                return 1
            fi
            
        elif command -v dnf &> /dev/null; then
            # Fedora/RHEL
            log_info "Using dnf with Microsoft repository..."
            
            # Import Microsoft GPG key
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            
            # Add VS Code repository
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | \
                sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
            
            # Install VS Code
            if sudo dnf install -y code; then
                log_success "Installed via dnf"
            else
                log_error "dnf install failed"
                return 1
            fi
            
        elif command -v snap &> /dev/null; then
            # Fallback to Snap if available
            log_info "Using snap..."
            if sudo snap install code --classic; then
                log_success "Installed via snap"
            else
                log_error "snap install failed"
                return 1
            fi
            
        else
            log_error "No supported package manager found"
            return 1
        fi
    else
        log_error "Unsupported operating system: $OSTYPE"
        return 1
    fi
    
    # Verify installation
    if command -v code &> /dev/null; then
        NEW_VERSION=$(code --version 2>/dev/null | head -n1)
        log_success "VS Code installed successfully: $NEW_VERSION"
        log_info "You can now use 'code .' to open VS Code in the current directory"
        return 0
    else
        log_error "Installation verification failed"
        return 1
    fi
}

# Run installation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_vscode
fi