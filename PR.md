# Pull Request: Raspberry Pi Integration for Dotfiles

## Overview

This PR adds comprehensive Raspberry Pi support to our dotfiles repository, enabling automated setup and configuration of Raspberry Pi devices with our preferred environment.

## Features

### 1. Command-Line SD Card Flashing
- Added `flash-sd.sh` script for flashing Raspberry Pi OS from command line
- Supports automatic download of latest OS image
- Configures WiFi and SSH for headless setup
- Sets custom hostname

### 2. Raspberry Pi Specific Setup
- Created `setup.sh` script for Pi-specific configuration
- Installs development packages (Python, GPIO libraries, MQTT)
- Sets up project directory structure
- Configures services (Node-RED, MQTT broker)

### 3. Dotfiles Integration
- Modified main `setup.sh` to detect Raspberry Pi hardware
- Automatically runs Pi-specific setup when detected
- Adds Pi-specific bash aliases and functions

### 4. Headless Setup Support
- Added configuration files for headless setup
- Documented the process for setting up without monitor/keyboard

## Testing Done

- Tested SD card flashing script with error handling
- Verified dotfiles integration with Raspberry Pi environment
- Confirmed headless setup process works as expected

## How to Test

1. Flash an SD card using the script:
   ```bash
   cd ~/dotfiles/raspberry-pi
   ./flash-sd.sh --device /dev/sdX --wifi YourNetwork:YourPassword
   ```

2. Boot the Pi and SSH in:
   ```bash
   ssh pi@raspberrypi.local
   ```

3. Clone and run the dotfiles setup:
   ```bash
   git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ```

4. Verify the Pi-specific environment is set up correctly:
   - Check for GPIO libraries
   - Test MQTT broker
   - Verify Node-RED is running

## Screenshots

N/A - Command-line tools

## Related Issues

Closes #XX - Add Raspberry Pi support to dotfiles
