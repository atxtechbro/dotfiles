#!/bin/bash
# Linux Mint / Cinnamon Desktop Configuration
# Self-healing system configuration following the spilled coffee principle
#
# This script applies Linux Mint-specific system preferences using gsettings
# Designed to be idempotent (safe to run multiple times) and platform-aware

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

configure_linux_mint() {
    echo "Checking for Linux Mint desktop configuration..."

    # Only run on systems with gsettings (GNOME/Cinnamon/MATE desktops)
    if ! command -v gsettings &> /dev/null; then
        return 0
    fi

    # Check if this is actually Linux Mint by checking for Nemo schemas
    if ! gsettings list-schemas | grep -q "org.nemo.preferences"; then
        return 0
    fi

    echo "Detected Cinnamon desktop environment. Configuring Nemo file manager..."

    # Nemo File Manager Preferences
    # Following the temporal order > category grouping principle

    # TEMPORAL ORDER PREFERENCE
    # Disable folders-first sorting to show true chronological timeline
    # This makes Downloads show files/folders mixed by modification time
    # instead of grouping all folders at the top
    # Rationale: Temporal order is more useful than arbitrary categorization
    gsettings set org.nemo.preferences sort-directories-first false

    # Additional quality-of-life settings can be added here in the future
    # Examples:
    # gsettings set org.nemo.preferences show-hidden-files true
    # gsettings set org.nemo.preferences show-full-path-titles true

    echo -e "${GREEN}✓ Nemo file manager configured with temporal-order sorting${NC}"
    echo -e "  - Folders and files now sorted together by modification time"

    return 0
}

# Allow script to be run directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_linux_mint
fi
