#!/bin/bash

# =========================================================
# AMAZON Q CLI AUTO-INSTALLER AND CONFIGURATOR
# =========================================================
# PURPOSE: Automatically install, update, and configure Amazon Q CLI
# This follows the "spilled coffee principle" - users should be
# fully operational after running setup without manual intervention
# =========================================================

# Define colors for consistent output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Installation Functions ---

install_amazon_q_linux() {
    local arch="$1"
    local q_arch=""

    # Map architecture names for Linux
    case "$arch" in
        "x86_64")
            q_arch="x86_64"
            ;;
        "aarch64")
            q_arch="aarch64"
            ;;
        *)
            echo -e "${RED}Unsupported architecture for Linux: $arch${NC}"
            echo "Please install Amazon Q CLI manually."
            return 1
            ;;
    esac

    # Construct download URL for minimal installation (zip file method)
    local base_url="https://desktop-release.q.us-east-1.amazonaws.com/latest"
    local filename="q-${q_arch}-linux.zip"
    local download_url="${base_url}/${filename}"

    echo "Downloading Amazon Q CLI for Linux ${q_arch}..."
    echo "This includes the 'q' command and 'qterm' for autocomplete."

    # Create temporary directory for the download
    local temp_dir
    temp_dir=$(mktemp -d)
    if [ ! -d "$temp_dir" ]; then
        echo -e "${RED}Failed to create temporary directory${NC}"
        return 1
    fi
    cd "$temp_dir" || return 1

    # Download the zip file
    if ! curl --proto '=https' --tlsv1.2 -sSfL "$download_url" -o "q.zip"; then
        echo -e "${RED}Failed to download Amazon Q CLI from $download_url${NC}"
        echo "Please check your internet connection or install manually."
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract and run the installer
    if unzip -q q.zip; then
        if [[ -f "q/install.sh" ]]; then
            chmod +x q/install.sh
            echo "Running Amazon Q CLI installer..."
            if ./q/install.sh --no-confirm; then
                echo -e "${GREEN}✓ Amazon Q CLI minimal installation completed${NC}"
                rm -rf "$temp_dir"

                # Verify installation and provide guidance if PATH needs update
                if command -v q >/dev/null 2>&1; then
                    local version
                    version=$(q --version 2>/dev/null | head -n 1 || echo "installed")
                    echo -e "${GREEN}✓ Amazon Q CLI ready: $version${NC}"
                else
                    echo -e "${YELLOW}Amazon Q CLI installed to ~/.local/bin${NC}"
                    echo -e "${YELLOW}You may need to restart your terminal or run: export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
                fi
                return 0
            fi
        else
            echo -e "${RED}Installation script 'q/install.sh' not found in archive${NC}"
        fi
    else
        echo -e "${RED}Failed to extract Amazon Q CLI archive${NC}"
    fi

    echo -e "${RED}Amazon Q CLI installation failed${NC}"
    rm -rf "$temp_dir"
    return 1
}

install_amazon_q_macos() {
    # On macOS, Homebrew is the preferred installation method.
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Homebrew is required to install Amazon Q CLI on macOS.${NC}"
        echo "Please install Homebrew first: https://brew.sh/"
        return 1
    fi

    echo "Installing Amazon Q CLI via Homebrew..."
    if brew install --cask amazon-q; then
        echo -e "${GREEN}✓ Amazon Q CLI installed successfully via Homebrew${NC}"

        # Verify installation
        if command -v q >/dev/null 2>&1; then
            local version
            version=$(q --version 2>/dev/null | head -n 1 || echo "unknown")
            echo -e "${GREEN}✓ Amazon Q CLI version: $version${NC}"
        else
            echo -e "${YELLOW}Amazon Q CLI installed but 'q' command is not in PATH.${NC}"
            echo "Please open the Amazon Q application and enable shell integrations."
        fi
        return 0
    else
        echo -e "${RED}Failed to install Amazon Q CLI via Homebrew.${NC}"
        echo "You can try a manual install by downloading from:"
        echo "https://desktop-release.q.us-east-1.amazonaws.com/latest/Amazon%20Q.dmg"
        return 1
    fi
}

install_amazon_q() {
    echo -e "${YELLOW}Amazon Q CLI not found. Starting installation...${NC}"
    local arch
    arch=$(uname -m)

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        install_amazon_q_linux "$arch"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        install_amazon_q_macos
    else
        echo -e "${RED}Unsupported OS: $OSTYPE. Please install Amazon Q CLI manually.${NC}"
        echo "Visit: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html"
        return 1
    fi
}

# --- Update Function ---

update_amazon_q() {
    if ! command -v q >/dev/null 2>&1; then
        echo -e "${YELLOW}Amazon Q CLI not installed, skipping update check.${NC}"
        return
    fi

    echo "Checking for Amazon Q CLI updates..."
    # Check if an update is available.
    if q update 2>&1 | grep -q "A new version of q is available:"; then
        echo "Amazon Q update available. Attempting to install..."

        if [[ "$OSTYPE" == "darwin"* ]]; then
            # On macOS, use Homebrew to upgrade
            if command -v brew &> /dev/null; then
                if brew upgrade --cask amazon-q; then
                    echo -e "${GREEN}✓ Amazon Q updated successfully via Homebrew${NC}"
                else
                    echo -e "${YELLOW}Homebrew upgrade failed. Please try running 'brew upgrade --cask amazon-q' manually.${NC}"
                fi
            else
                echo -e "${YELLOW}Homebrew not found. Cannot automatically update. Please update manually.${NC}"
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # On Linux, re-run the installer which handles updates.
            echo "Re-running Linux installer to update..."
            local arch
            arch=$(uname -m)
            install_amazon_q_linux "$arch"
        fi
    else
        echo -e "${GREEN}✓ Amazon Q is up to date${NC}"
    fi
}


# --- Configuration Function ---

configure_amazon_q() {
    if ! command -v q >/dev/null 2>&1; then
        echo -e "${YELLOW}Amazon Q CLI not installed, skipping configuration.${NC}"
        return 1
    fi

    echo "Configuring Amazon Q settings..."

    # Configure settings with error handling
    q telemetry disable >/dev/null 2>&1 || echo -e "${YELLOW}Could not disable telemetry (might already be disabled)${NC}"
    q settings chat.editMode vi >/dev/null 2>&1 || echo -e "${YELLOW}Could not set chat.editMode to vi${NC}"
    q settings chat.defaultModel claude-4-sonnet >/dev/null 2>&1 || echo -e "${YELLOW}Could not set default model${NC}"
    q settings mcp.noInteractiveTimeout 5000 >/dev/null 2>&1 || echo -e "${YELLOW}Could not set mcp.noInteractiveTimeout${NC}"

    echo -e "${GREEN}✓ Amazon Q configuration complete${NC}"
}


# --- Main Setup Function ---

setup_amazon_q() {
    # Check if Amazon Q CLI is already installed
    if command -v q >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Amazon Q CLI is already installed${NC}"
        update_amazon_q
        configure_amazon_q
    else
        # Install and then configure
        if install_amazon_q; then
            configure_amazon_q
        else
            echo -e "${RED}Setup failed because Amazon Q installation did not succeed.${NC}"
            return 1
        fi
    fi
}

# If script is executed directly (not sourced), run the setup function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_amazon_q
fi
