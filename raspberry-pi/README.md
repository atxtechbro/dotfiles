# Raspberry Pi Headless Setup

This directory contains Raspberry Pi specific configurations and scripts for headless setup (without keyboard or monitor, using SSH only).

## Quick Setup

### 1. Flash Raspberry Pi OS to MicroSD Card

Use the included command-line script to flash Raspberry Pi OS:

```bash
# Show available devices
lsblk

# Flash with WiFi and custom hostname
./raspberry-pi/flash-sd.sh --device /dev/sdX --wifi YourNetwork:YourPassword --hostname mypi
```

The script will:
- Download the latest Raspberry Pi OS image
- Flash it to your MicroSD card
- Configure WiFi and SSH for headless setup
- Set your preferred hostname

### 2. Connect to Your Pi

After flashing:

1. Insert the card into your Pi and power it on
2. Wait about 90 seconds for the Pi to boot
3. Connect via SSH:
   ```bash
   # Using hostname (if your router supports mDNS)
   ssh pi@mypi.local
   
   # Or using IP address (find it from your router)
   ssh pi@192.168.1.xxx
   ```

### 3. Install Dotfiles

Once connected:

```bash
git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The setup script will detect that it's running on a Raspberry Pi and automatically run the Raspberry Pi specific setup script.

## Headless Setup Options

The Raspberry Pi setup script offers several installation options:

1. **Minimal setup** - Basic tools for headless servers
2. **Development environment** - Python, GPIO libraries, and development tools
3. **IoT environment** - MQTT broker, Node-RED, and IoT tools
4. **All components** - Complete installation with all features

## Configuration Files

- `config.txt` - Settings to add to `/boot/config.txt`
- `templates/` - Template files used by the flash script

## Useful Commands

After setup, you'll have these commands available:

- `temp` - Show CPU temperature
- `freq` - Show CPU frequency
- `mem` - Show memory usage
- `pitemp` - Show formatted CPU temperature
- `gpio` - Simplified GPIO control
- `pisystem` - Show system information
- `headless-setup` - Interactive script for configuring static IP, SSH hardening, and automatic updates

## Project Structure

The setup creates this directory structure:

```
~/projects/raspberry-pi/
├── bin/         # Scripts and executables
├── config/      # Configuration files
├── data/        # Data files
├── logs/        # Log files
├── scripts/     # Project scripts
├── src/         # Source code
├── web/         # Web interface files
├── venv/        # Python virtual environment
└── .env         # Environment variables
```

## Python Package Management

This setup uses `uv` instead of `pip` for Python package management, following project standards. `uv` is faster and more reliable than traditional pip.

```bash
# Install a package
uv pip install package-name

# Install multiple packages
uv pip install package1 package2

# Install from requirements.txt
uv pip install -r requirements.txt
```

## Security Features

The setup includes several security features for headless operation:

- SSH hardening options
- Firewall configuration with UFW
- Automatic security updates
- MQTT broker configured for local connections only by default

## Services

The IoT setup configures these services:

- MQTT broker (mosquitto) on port 1883 (localhost only by default)
- Node-RED on port 1880
