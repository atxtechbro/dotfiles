#!/bin/bash
# Setup script for Amazon Q CLI build environment
# This script installs all dependencies required to build Amazon Q CLI from source

set -e

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
DIVIDER="----------------------------------------"

echo -e "${DIVIDER}"
echo -e "${BLUE}Setting up Amazon Q CLI build environment...${NC}"
echo -e "${DIVIDER}"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
    echo "Detected OS: Linux"
    
    # Detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        echo "Detected distribution: $DISTRO"
    else
        DISTRO="unknown"
        echo "Could not detect Linux distribution"
    fi
    
    # Install dependencies based on distribution
    case $DISTRO in
        ubuntu|debian|pop|linuxmint)
            echo "Installing dependencies for $DISTRO..."
            sudo apt update
            sudo apt install -y build-essential pkg-config jq dpkg curl wget zstd cmake clang \
                libssl-dev libgtk-3-dev libwebkit2gtk-4.0-dev libappindicator3-dev \
                librsvg2-dev patchelf python3 python3-pip nodejs npm
            ;;
        arch|manjaro)
            echo "Installing dependencies for $DISTRO..."
            sudo pacman -Sy --noconfirm base-devel pkg-config jq curl wget zstd cmake clang \
                openssl gtk3 webkit2gtk libappindicator-gtk3 librsvg patchelf python python-pip nodejs npm
            ;;
        fedora|rhel|centos)
            echo "Installing dependencies for $DISTRO..."
            sudo dnf install -y gcc gcc-c++ make pkg-config jq dpkg curl wget zstd cmake clang \
                openssl-devel gtk3-devel webkit2gtk3-devel libappindicator-gtk3 librsvg2-devel \
                patchelf python3 python3-pip nodejs npm
            ;;
        *)
            echo -e "${YELLOW}Unsupported Linux distribution: $DISTRO${NC}"
            echo "Please install the following dependencies manually:"
            echo "- build-essential (or equivalent)"
            echo "- pkg-config"
            echo "- jq"
            echo "- curl, wget"
            echo "- zstd"
            echo "- cmake, clang"
            echo "- libssl-dev (or equivalent)"
            echo "- libgtk-3-dev (or equivalent)"
            echo "- libwebkit2gtk-4.0-dev (or equivalent)"
            echo "- libappindicator3-dev (or equivalent)"
            echo "- librsvg2-dev (or equivalent)"
            echo "- patchelf"
            echo "- python3, python3-pip"
            echo "- nodejs, npm"
            ;;
    esac
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
    echo "Detected OS: macOS"
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed. Updating..."
        brew update
    fi
    
    # Install dependencies
    echo "Installing dependencies..."
    brew install protobuf fish shellcheck python node
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

# Install Rust
echo -e "${DIVIDER}"
echo -e "${BLUE}Setting up Rust...${NC}"

if ! command -v rustup &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust is already installed. Updating..."
    rustup update
fi

# Install required Rust components
rustup component add rustfmt clippy

# Set up Python environment
echo -e "${DIVIDER}"
echo -e "${BLUE}Setting up Python environment...${NC}"

# Install mise if not already installed
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    
    # Add mise to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Add mise to shell configuration if not already there
    if ! grep -q "mise activate" "$HOME/.bashrc"; then
        echo 'eval "$(mise activate bash)"' >> "$HOME/.bashrc"
    fi
    
    # Source mise for current session
    eval "$(mise activate bash)"
else
    echo "mise is already installed"
fi

# Set up Node.js environment
echo -e "${DIVIDER}"
echo -e "${BLUE}Setting up Node.js environment...${NC}"

# Ensure NVM directory exists
export NVM_DIR="$HOME/.nvm"

# Install NVM if not already installed
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Source NVM immediately after installation
    if [ -d "$NVM_DIR" ]; then
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            # shellcheck source=/dev/null
            . "$NVM_DIR/nvm.sh"
        fi
    fi
    
    # Install latest LTS version of Node.js and set as default
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
else
    # Source NVM if it exists
    if [ -d "$NVM_DIR" ]; then
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            # shellcheck source=/dev/null
            . "$NVM_DIR/nvm.sh"
        fi
    fi
    
    # Check if NVM is available
    if command -v nvm &> /dev/null; then
        echo "NVM is already installed. Installing latest LTS Node.js..."
        nvm install --lts
        nvm use --lts
    else
        echo -e "${YELLOW}NVM installation found but not working properly.${NC}"
        echo "Please fix your NVM installation or install Node.js manually."
    fi
fi

# Create directory for Amazon Q CLI repository
mkdir -p "$HOME/ppv/pillars"

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Amazon Q CLI build environment setup complete!${NC}"
echo -e "You can now build Amazon Q CLI from source using:"
echo -e "${BLUE}./build-amazon-q-from-source.sh${NC}"
echo -e "${DIVIDER}"
