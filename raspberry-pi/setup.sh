#!/bin/bash

# Main setup script for Raspberry Pi configurations
# This script detects the Raspberry Pi model and guides the user through setup

echo "Raspberry Pi Setup - Dotfiles Configuration"
echo "=========================================="
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
