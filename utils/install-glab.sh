#!/bin/bash

# =========================================================
# GITLAB CLI (GLAB) INSTALLATION UTILITY SCRIPT
# =========================================================
# PURPOSE: Provides automated GitLab CLI installation across different platforms
# This script follows the "spilled coffee principle" by ensuring GitLab CLI
# is available without manual intervention
# =========================================================

# Function to install GitLab CLI based on the detected OS
install_glab() {
    local OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    local ARCH=$(uname -m)
    
    # Map architecture to GitLab CLI naming convention
    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="arm"
            ;;
        i*86)
            ARCH="386"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
    
    echo "Installing GitLab CLI for $OS-$ARCH..."
    
    # Create temporary directory for download
    local TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get the latest release version
    echo "Fetching latest GitLab CLI release..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/gl-cli/glab/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: Failed to determine latest GitLab CLI version"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    echo "Latest version: $LATEST_VERSION"
    
    # Download and install GitLab CLI based on OS
    case "$OS" in
        linux)
            # Try package manager first
            if command -v apt-get &> /dev/null; then
                echo "Detected apt-based system, attempting to install GitLab CLI via apt..."
                if ! command -v gpg &> /dev/null; then
                    sudo apt-get update
                    sudo apt-get install -y gpg
                fi
                
                # Add GitLab CLI repository
                curl -fsSL https://gitlab.com/gitlab-org/cli/-/raw/main/scripts/install.sh | sudo bash
                
                if command -v glab &> /dev/null; then
                    echo "GitLab CLI installed successfully via apt"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "apt installation failed, falling back to manual installation..."
                fi
            elif command -v dnf &> /dev/null; then
                echo "Detected dnf-based system, attempting to install GitLab CLI via dnf..."
                sudo dnf install -y glab
                if command -v glab &> /dev/null; then
                    echo "GitLab CLI installed successfully via dnf"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "dnf installation failed, falling back to manual installation..."
                fi
            elif command -v pacman &> /dev/null; then
                echo "Detected Arch-based system, attempting to install GitLab CLI via pacman..."
                sudo pacman -Sy --noconfirm glab
                if command -v glab &> /dev/null; then
                    echo "GitLab CLI installed successfully via pacman"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "pacman installation failed, falling back to manual installation..."
                fi
            fi
            
            # Manual installation if package manager failed or isn't available
            echo "Installing GitLab CLI manually from official distribution..."
            DOWNLOAD_URL="https://github.com/gl-cli/glab/releases/download/v${LATEST_VERSION}/glab_${LATEST_VERSION}_${OS}_${ARCH}.tar.gz"
            echo "Downloading from: $DOWNLOAD_URL"
            
            curl -L "$DOWNLOAD_URL" -o "glab.tar.gz"
            tar -xzf glab.tar.gz
            
            # Install the binary
            mkdir -p "$HOME/.local/bin"
            cp bin/glab "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/glab"
            
            # Add to PATH if not already there
            if ! grep -q "export PATH=\$PATH:\$HOME/.local/bin" ~/.bashrc; then
                echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
            fi
            
            # Make available in current session
            export PATH=$PATH:$HOME/.local/bin
            ;;
            
        darwin)
            # Try Homebrew first
            if command -v brew &> /dev/null; then
                echo "Detected macOS with Homebrew, installing GitLab CLI via brew..."
                brew install glab
                if command -v glab &> /dev/null; then
                    echo "GitLab CLI installed successfully via Homebrew"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "Homebrew installation failed, falling back to manual installation..."
                fi
            fi
            
            # Manual installation if Homebrew failed or isn't available
            echo "Installing GitLab CLI manually from official distribution..."
            DOWNLOAD_URL="https://github.com/gl-cli/glab/releases/download/v${LATEST_VERSION}/glab_${LATEST_VERSION}_${OS}_${ARCH}.tar.gz"
            echo "Downloading from: $DOWNLOAD_URL"
            
            curl -L "$DOWNLOAD_URL" -o "glab.tar.gz"
            tar -xzf glab.tar.gz
            
            # Install the binary
            mkdir -p "$HOME/.local/bin"
            cp bin/glab "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/glab"
            
            # Add to PATH if not already there
            if ! grep -q "export PATH=\$PATH:\$HOME/.local/bin" ~/.zshrc; then
                echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
            fi
            
            # Make available in current session
            export PATH=$PATH:$HOME/.local/bin
            ;;
            
        *)
            echo "Unsupported operating system: $OS"
            rm -rf "$TEMP_DIR"
            return 1
            ;;
    esac
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    # Verify installation
    if command -v glab &> /dev/null; then
        echo "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        echo "Failed to install GitLab CLI. Please install it manually."
        return 1
    fi
}

# Function to update GitLab CLI if needed
update_glab() {
    if ! command -v glab &> /dev/null; then
        echo "GitLab CLI not found. Installing..."
        install_glab
        return $?
    fi
    
    echo "Checking for GitLab CLI updates..."
    
    # Get current version
    CURRENT_VERSION=$(glab --version | head -n 1 | grep -oP 'glab version \K[0-9]+\.[0-9]+\.[0-9]+')
    
    # Get latest version
    LATEST_VERSION=$(curl -s https://api.github.com/repos/gl-cli/glab/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Error: Failed to determine latest GitLab CLI version"
        return 1
    fi
    
    # Compare versions
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo "GitLab CLI is already at the latest version ($CURRENT_VERSION)"
        return 0
    else
        echo "Updating GitLab CLI from $CURRENT_VERSION to $LATEST_VERSION..."
        install_glab
        return $?
    fi
}

# Check if GitLab CLI is installed, install if not, update if outdated
ensure_glab_installed() {
    if ! command -v glab &> /dev/null; then
        echo "GitLab CLI is not installed. Installing GitLab CLI..."
        if ! install_glab; then
            echo "Error: Failed to install GitLab CLI automatically. Please install GitLab CLI manually."
            echo "Visit https://github.com/gl-cli/glab#installation for installation instructions."
            return 1
        fi
    else
        echo "GitLab CLI is already installed: $(glab --version | head -n 1)"
        update_glab
    fi
    
    return 0
}

# If script is executed directly (not sourced), run the installation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ensure_glab_installed
fi
