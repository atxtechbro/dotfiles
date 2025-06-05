#!/bin/bash

# Main setup script for Raspberry Pi configurations
# This script detects the Raspberry Pi model and guides the user through setup

echo "Raspberry Pi Setup - Dotfiles Configuration"
echo "=========================================="
echo

# Install xterm for emergency terminal access in kiosk mode
echo "Installing xterm and required fonts for emergency terminal access..."
sudo apt update && sudo apt install -y xterm xfonts-base xfonts-75dpi xfonts-100dpi lxterminal
echo "xterm and lxterminal installed successfully."
echo "To open a terminal in kiosk mode:"
echo "  - From SSH: run 'DISPLAY=:0 lxterminal &' or 'DISPLAY=:0 xterm -fn fixed &'"
echo "  - From keyboard: press Alt+F2 and type 'lxterminal' (if run dialog works)"
echo

# Check if running on a Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo &> /dev/null; then
    echo "Error: This script must be run on a Raspberry Pi."
    echo "If you are on a Raspberry Pi and seeing this error, please report this issue."
    exit 1
fi

# Detect Raspberry Pi model
PI_MODEL=$(grep "Model" /proc/cpuinfo | sed 's/.*: //')
echo "Detected: $PI_MODEL"

# Detect RAM
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
echo "Memory: ${TOTAL_RAM}MB RAM"

# Detect storage
ROOT_PARTITION_SIZE=$(df -h / | awk 'NR==2 {print $2}')
echo "Root partition size: $ROOT_PARTITION_SIZE"

echo
echo "This setup script will guide you through configuring your Raspberry Pi."
echo "The following steps are fully implemented:"
echo "- SD card preparation"
echo "- Smart TV Dashboard / Kiosk Mode"
echo
echo "Please follow the step-by-step guides in the README.md file."
echo
echo "Next steps:"
echo "1. Review the hardware setup guide: 02-hardware-setup.md"
echo "2. Complete the first boot process: 03-first-boot.md"
echo "3. Choose your specific use case: 04-choose-use-case.md"
echo "4. For kiosk mode setup: 05-smart-tv-dashboard-kiosk.md"
echo
echo "For more information, see the README.md file."

# Install AWS CLI
echo "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    # Install dependencies
    sudo apt update && sudo apt install -y unzip curl python3-pip
    
    # Install AWS CLI v2 for ARM architecture
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    
    # Verify installation
    aws --version
    echo "AWS CLI installed successfully."
else
    echo "AWS CLI is already installed: $(aws --version)"
fi
echo
