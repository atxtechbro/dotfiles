#!/bin/bash

# =========================================================
# GO INSTALLATION UTILITY SCRIPT
# =========================================================
# PURPOSE: Provides automated Go installation across different platforms
# This script follows the "spilled coffee principle" by ensuring Go
# is available without manual intervention
# =========================================================

# Function to install Go based on the detected OS
install_go() {
    local GO_VERSION="1.21.5"  # Update this to the latest stable version as needed
    local OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    local ARCH=$(uname -m)
    
    # Map architecture to Go's naming convention
    case "$ARCH" in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        armv*)
            ARCH="armv6l"
            ;;
        i*86)
            ARCH="386"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
    
    echo "Installing Go $GO_VERSION for $OS-$ARCH..."
    
    # Create temporary directory for download
    local TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download and install Go based on OS
    case "$OS" in
        linux)
            # Try package manager first
            if command -v apt-get &> /dev/null; then
                echo "Detected apt-based system, attempting to install Go via apt..."
                sudo apt-get update
                sudo apt-get install -y golang
                if command -v go &> /dev/null; then
                    echo "Go installed successfully via apt"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "apt installation failed, falling back to manual installation..."
                fi
            elif command -v dnf &> /dev/null; then
                echo "Detected dnf-based system, attempting to install Go via dnf..."
                sudo dnf install -y golang
                if command -v go &> /dev/null; then
                    echo "Go installed successfully via dnf"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "dnf installation failed, falling back to manual installation..."
                fi
            elif command -v pacman &> /dev/null; then
                echo "Detected Arch-based system, attempting to install Go via pacman..."
                sudo pacman -Sy --noconfirm go
                if command -v go &> /dev/null; then
                    echo "Go installed successfully via pacman"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "pacman installation failed, falling back to manual installation..."
                fi
            fi
            
            # Manual installation if package manager failed or isn't available
            echo "Installing Go manually from official distribution..."
            curl -L "https://go.dev/dl/go${GO_VERSION}.${OS}-${ARCH}.tar.gz" -o "go.tar.gz"
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go.tar.gz
            
            # Add Go to PATH if not already there
            if ! grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.bashrc; then
                echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
                echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
            fi
            
            # Make Go available in current session
            export PATH=$PATH:/usr/local/go/bin
            export PATH=$PATH:$HOME/go/bin
            ;;
            
        darwin)
            # Try Homebrew first
            if command -v brew &> /dev/null; then
                echo "Detected macOS with Homebrew, installing Go via brew..."
                brew install go
                if command -v go &> /dev/null; then
                    echo "Go installed successfully via Homebrew"
                    rm -rf "$TEMP_DIR"
                    return 0
                else
                    echo "Homebrew installation failed, falling back to manual installation..."
                fi
            fi
            
            # Manual installation if Homebrew failed or isn't available
            echo "Installing Go manually from official distribution..."
            curl -L "https://go.dev/dl/go${GO_VERSION}.${OS}-${ARCH}.tar.gz" -o "go.tar.gz"
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go.tar.gz
            
            # Add Go to PATH if not already there
            if ! grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.zshrc; then
                echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
                echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc
            fi
            
            # Make Go available in current session
            export PATH=$PATH:/usr/local/go/bin
            export PATH=$PATH:$HOME/go/bin
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
    if command -v go &> /dev/null; then
        echo "Go $GO_VERSION installed successfully!"
        go version
        return 0
    else
        echo "Failed to install Go. Please install it manually."
        return 1
    fi
}

# Function to set up Go environment
setup_go_env() {
    # Set up Go environment variables if not already set
    if [ -z "$GOPATH" ]; then
        export GOPATH=$HOME/go
        echo "GOPATH set to $GOPATH"
    fi

    # Create Go workspace directories if they don't exist
    mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"
}

# Check if Go is installed, install if not
ensure_go_installed() {
    if ! command -v go &> /dev/null; then
        echo "Go is not installed. Installing Go..."
        if ! install_go; then
            echo "Error: Failed to install Go automatically. Please install Go manually."
            echo "Visit https://golang.org/doc/install for installation instructions."
            return 1
        fi
    else
        echo "Go is already installed: $(go version)"
    fi
    
    # Set up Go environment regardless of whether we just installed it or it was already there
    setup_go_env
    return 0
}

# If script is executed directly (not sourced), run the installation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ensure_go_installed
fi
