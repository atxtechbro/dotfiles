# Raspberry Pi 5 Headless Setup

This directory contains configurations and scripts for headless setup of a Raspberry Pi 5 (8GB) with a 128GB Samsung microSD card.

## Quick Setup

### 1. Flash Raspberry Pi OS to MicroSD Card

First, identify your 128GB Samsung microSD card:

```bash
# Show all storage devices
lsblk -p -o NAME,SIZE,MODEL,VENDOR
```

Look for the 128GB Samsung device in the output. Then flash the OS:

```bash
# Flash with WiFi and custom hostname
./raspberry-pi/flash-sd.sh --device /dev/sdX --wifi YourNetwork:YourPassword --hostname pi5
```

The script will:
- Download the latest 64-bit Raspberry Pi OS image
- Flash it to your 128GB Samsung microSD card
- Configure WiFi and SSH for headless setup
- Set your preferred hostname

### 2. Connect to Your Pi 5

After flashing:

1. Insert the card into your Pi 5 and power it on
2. Wait about 60 seconds for the Pi to boot
3. Connect via SSH:
   ```bash
   # Using hostname
   ssh pi@pi5.local
   
   # Or using IP address (if hostname resolution fails)
   ssh pi@192.168.1.xxx
   ```

Default credentials: username `pi`, password `raspberry`

### 3. Install Dotfiles

Once connected:

```bash
git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The setup script will detect the Raspberry Pi 5 and optimize configurations for the 8GB model.

## Raspberry Pi 5 Optimizations

The setup automatically applies these Pi 5 specific optimizations:

- Memory allocation optimized for 8GB RAM model
- Storage partitioning optimized for 128GB Samsung microSD
- CPU governor settings for optimal performance/temperature balance
- GPU memory allocation for headless operation
- USB port power management for connected peripherals

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

This setup uses `uv` for Python package management:

```bash
# Install a package
uv pip install package-name

# Install from requirements.txt
uv pip install -r requirements.txt
```

## Security Features

The setup includes security features for headless operation:

- SSH hardening options
- Firewall configuration with UFW
- Automatic security updates
- MQTT broker configured for local connections only by default

## Services

The IoT setup configures these services:

- MQTT broker (mosquitto) on port 1883 (localhost only by default)
- Node-RED on port 1880
