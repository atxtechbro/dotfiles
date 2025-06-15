#!/bin/bash
# Install act - GitHub Actions local testing tool
# Provides faster feedback loops by running GitHub Actions locally

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

install_act() {
    echo "Setting up act (GitHub Actions local testing tool)..."
    
    if command -v act &> /dev/null; then
        echo -e "${GREEN}✓ act is already installed${NC}"
        return 0
    fi
    
    echo "Installing act for faster GitHub Actions feedback loops..."
    
    # Try apt install first (works on Ubuntu/Debian systems)
    if command -v apt &> /dev/null; then
        echo "Attempting to install act via apt..."
        if sudo apt update &>/dev/null && sudo apt install -y act &>/dev/null; then
            echo -e "${GREEN}✓ act installed successfully via apt${NC}"
            return 0
        else
            echo -e "${YELLOW}apt install failed, trying alternative installation method...${NC}"
        fi
    fi
    
    # Try pacman for Arch Linux
    if command -v pacman &> /dev/null; then
        echo "Installing act via pacman..."
        if sudo pacman -S --noconfirm act &>/dev/null; then
            echo -e "${GREEN}✓ act installed successfully via pacman${NC}"
            return 0
        else
            echo -e "${RED}Failed to install act via pacman${NC}"
        fi
    fi
    
    # Try Homebrew for macOS
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
        echo "Installing act via Homebrew..."
        if brew install act &>/dev/null; then
            echo -e "${GREEN}✓ act installed successfully via Homebrew${NC}"
            return 0
        else
            echo -e "${RED}Failed to install act via Homebrew${NC}"
        fi
    fi
    
    # Fallback: Install via GitHub releases
    echo "Installing act from GitHub releases..."
    if command -v curl &> /dev/null; then
        # Get latest release URL
        LATEST_URL=$(curl -s https://api.github.com/repos/nektos/act/releases/latest | grep "browser_download_url.*Linux_x86_64.tar.gz" | cut -d '"' -f 4)
        
        if [[ -n "$LATEST_URL" ]]; then
            # Create temporary directory
            TMP_DIR=$(mktemp -d)
            cd "$TMP_DIR" || return 1
            
            # Download and extract
            if curl -L "$LATEST_URL" -o act.tar.gz &>/dev/null && tar -xzf act.tar.gz &>/dev/null; then
                # Install to user's local bin
                mkdir -p "$HOME/.local/bin"
                mv act "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/act"
                
                # Clean up
                cd - &>/dev/null || return 1
                rm -rf "$TMP_DIR"
                
                echo -e "${GREEN}✓ act installed successfully from GitHub releases${NC}"
                return 0
            else
                echo -e "${RED}Failed to download or extract act from GitHub releases${NC}"
                rm -rf "$TMP_DIR"
                return 1
            fi
        else
            echo -e "${RED}Failed to get latest act release URL${NC}"
            return 1
        fi
    else
        echo -e "${RED}curl not available for fallback installation${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}No supported installation method found for act${NC}"
    echo "Please install act manually from: https://github.com/nektos/act"
    return 1
}

verify_act_installation() {
    if command -v act &> /dev/null; then
        ACT_VERSION=$(act --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${GREEN}✓ act is available: ${ACT_VERSION}${NC}"
        
        # Check if Docker is available for act
        if command -v docker &> /dev/null; then
            echo -e "${GREEN}✓ act can use Docker for local GitHub Actions testing${NC}"
        else
            echo -e "${YELLOW}Docker not found. act requires Docker to run GitHub Actions locally.${NC}"
            echo "Install Docker to use act for local testing."
        fi
        return 0
    else
        echo -e "${YELLOW}act installation was attempted but command not found${NC}"
        echo "You may need to restart your terminal or add ~/.local/bin to your PATH"
        return 1
    fi
}

# Main function to set up act
setup_act() {
    install_act
    verify_act_installation
}

# If script is run directly (not sourced), execute setup
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_act
fi
