# Raspberry Pi Configuration

This directory contains Raspberry Pi specific configurations and scripts for headless setup (without keyboard or monitor, using SSH only).

## Setup Process

### 1. Flash Raspberry Pi OS to MicroSD Card

Use the included command-line script to flash Raspberry Pi OS:

```bash
# Show available devices
lsblk

# Flash with WiFi and custom hostname
./flash-sd.sh --device /dev/sdX --wifi YourNetwork:YourPassword --hostname mypi
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

The setup script will detect that it's running on a Raspberry Pi and automatically:

1. Install Raspberry Pi specific packages
2. Set up a Python virtual environment
3. Configure MQTT and Node-RED
4. Create useful aliases and functions
5. Set up project directories

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

## Project Structure

The setup creates this directory structure:

```
~/projects/raspberry-pi-project/
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

## Services

The setup configures these services:

- MQTT broker (mosquitto) on port 1883
- Node-RED on port 1880
