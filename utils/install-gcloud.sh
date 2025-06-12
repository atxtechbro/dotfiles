#!/bin/bash

# =========================================================
# GOOGLE CLOUD SDK INSTALLATION UTILITY
# =========================================================
# PURPOSE: Cross-platform gcloud CLI installation
# Supports macOS, Linux, and detects package managers
# Following the "Spilled Coffee Principle" - reproducible setup
# =========================================================

set -e  # Exit on any error

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing Google Cloud SDK...${NC}"

# Detect OS and install accordingly
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo -e "${BLUE}Detected macOS - using Homebrew${NC}"
    
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Error: Homebrew not installed${NC}"
        echo "Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    echo "Installing Google Cloud SDK via Homebrew..."
    brew install google-cloud-sdk
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    fi
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        echo -e "${BLUE}Detected Debian/Ubuntu - using apt${NC}"
        
        # Add Google Cloud SDK repository
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        
        # Import Google Cloud public key
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        
        # Update and install
        sudo apt-get update
        sudo apt-get install -y google-cloud-cli
        
    elif [[ "$OS" == *"Arch"* ]] || command -v pacman &> /dev/null; then
        echo -e "${BLUE}Detected Arch Linux - using pacman${NC}"
        sudo pacman -S --noconfirm google-cloud-cli
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
        echo -e "${BLUE}Detected Red Hat family - using yum/dnf${NC}"
        
        # Add Google Cloud SDK repository
        sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << 'EOM'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
        
        # Install using appropriate package manager
        if command -v dnf &> /dev/null; then
            sudo dnf install -y google-cloud-cli
        else
            sudo yum install -y google-cloud-cli
        fi
        
    else
        echo -e "${YELLOW}Unknown Linux distribution, using generic installation...${NC}"
        
        # Generic Linux installation
        curl https://sdk.cloud.google.com | bash
        exec -l $SHELL  # Restart shell to update PATH
    fi
    
else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    echo "Please install Google Cloud SDK manually: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Verify installation
if command -v gcloud &> /dev/null; then
    GCLOUD_VERSION=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null | head -n1)
    echo -e "${GREEN}✓ Google Cloud SDK installed successfully${NC}"
    echo -e "${GREEN}Version: $GCLOUD_VERSION${NC}"
    
    # Initialize gcloud if not already done
    if [ ! -f ~/.config/gcloud/configurations/config_default ]; then
        echo -e "${YELLOW}Initializing gcloud configuration...${NC}"
        echo "This will open a browser for authentication."
        read -p "Press Enter to continue with gcloud init..."
        gcloud init
    fi
    
else
    echo -e "${RED}Installation failed - gcloud command not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Google Cloud SDK setup complete${NC}"
