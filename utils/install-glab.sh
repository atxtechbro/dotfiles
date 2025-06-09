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
    
    # Get the latest release version from GitLab API
    echo "Fetching latest GitLab CLI release..."
    LATEST_VERSION=$(curl -s https://gitlab.com/api/v4/projects/34675721/releases | jq -r '.[0].tag_name' | sed 's/^v//')
    
    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
        echo "Error: Failed to determine latest GitLab CLI version"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    echo "Latest version: $LATEST_VERSION"
    
    # Download and install GitLab CLI based on OS
    case "$OS" in
        linux)
            # Install directly from GitLab releases for latest version
            echo "Installing GitLab CLI from official GitLab releases (ensures latest version)..."
            DOWNLOAD_URL="https://gitlab.com/gitlab-org/cli/-/releases/v${LATEST_VERSION}/downloads/glab_${LATEST_VERSION}_${OS}_${ARCH}.tar.gz"
            echo "Downloading from: $DOWNLOAD_URL"
            
            curl -L "$DOWNLOAD_URL" -o "glab.tar.gz"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to download GitLab CLI"
                rm -rf "$TEMP_DIR"
                return 1
            fi
            
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
            # Install directly from GitLab releases for latest version (preferred over Homebrew)
            echo "Installing GitLab CLI from official GitLab releases (ensures latest version)..."
            DOWNLOAD_URL="https://gitlab.com/gitlab-org/cli/-/releases/v${LATEST_VERSION}/downloads/glab_${LATEST_VERSION}_${OS}_${ARCH}.tar.gz"
            echo "Downloading from: $DOWNLOAD_URL"
            
            curl -L "$DOWNLOAD_URL" -o "glab.tar.gz"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to download GitLab CLI"
                rm -rf "$TEMP_DIR"
                return 1
            fi
            
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
        
        # Set telemetry to false in GitLab CLI config
        GLAB_CONFIG_DIR="$HOME/.config/glab-cli"
        GLAB_CONFIG_FILE="$GLAB_CONFIG_DIR/config.yml"
        
        if [ -f "$GLAB_CONFIG_FILE" ]; then
            echo "Setting GitLab CLI telemetry to false..."
            sed -i 's/^telemetry: true$/telemetry: false/' "$GLAB_CONFIG_FILE"
            echo "✓ Telemetry disabled in GitLab CLI configuration"
        else
            echo "GitLab CLI config file not found. Telemetry will be set to false on first run."
        fi
        
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
    CURRENT_VERSION=$(glab --version | head -n 1 | grep -oP 'glab \K[0-9]+\.[0-9]+\.[0-9]+')
    
    # Get latest version from GitLab API
    LATEST_VERSION=$(curl -s https://gitlab.com/api/v4/projects/34675721/releases | jq -r '.[0].tag_name' | sed 's/^v//')
    
    if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
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
