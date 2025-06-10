#!/bin/bash

# install-git-delta.sh - Automatic installation script for git-delta
# Following the "Spilled Coffee Principle" - making setup reproducible across machines

set -e  # Exit immediately if a command exits with a non-zero status

echo "Git Delta Installation Script"
echo "============================="

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Check if git-delta is already installed
if command -v delta &> /dev/null; then
    echo "Git Delta is already installed."
    delta --version
    exit 0
fi

echo "Installing Git Delta..."

# Install based on detected OS
if [[ "$OS" == "linux" ]]; then
    # Debian/Ubuntu-based systems
    if command -v apt-get &> /dev/null; then
        echo "Installing via apt..."
        sudo apt-get update
        sudo apt-get install -y git-delta
    
    # Arch Linux
    elif command -v pacman &> /dev/null; then
        echo "Installing via pacman..."
        sudo pacman -Sy --noconfirm git-delta
    
    # Fedora/RHEL-based systems
    elif command -v dnf &> /dev/null; then
        echo "Installing via dnf..."
        sudo dnf install -y git-delta
    
    # Fallback to binary installation
    else
        echo "No package manager found. Installing from binary..."
        
        # Determine architecture
        DELTA_ARCH=""
        case "$ARCH" in
            x86_64)
                DELTA_ARCH="x86_64"
                ;;
            aarch64|arm64)
                DELTA_ARCH="aarch64"
                ;;
            *)
                echo "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        
        # Get latest version
        VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
        
        # Download and install
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        FILENAME="delta-${VERSION}-${DELTA_ARCH}-unknown-linux-gnu.tar.gz"
        curl -L -o delta.tar.gz "https://github.com/dandavison/delta/releases/download/${VERSION}/${FILENAME}"
        
        tar xzf delta.tar.gz
        sudo install -o root -g root -m 0755 delta-*/delta /usr/local/bin/delta
        
        # Clean up
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    fi

elif [[ "$OS" == "darwin" ]]; then
    # macOS with Homebrew
    if command -v brew &> /dev/null; then
        echo "Installing via Homebrew..."
        brew install git-delta
    else
        echo "Homebrew not found. Please install Homebrew first."
        echo "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi

else
    echo "Unsupported operating system: $OS"
    exit 1
fi

# Verify installation
if command -v delta &> /dev/null; then
    echo "Git Delta installed successfully!"
    delta --version
else
    echo "Installation failed. Please install Git Delta manually."
    exit 1
fi
