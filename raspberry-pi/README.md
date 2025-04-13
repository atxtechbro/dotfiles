# Raspberry Pi Configuration

This directory contains Raspberry Pi specific configurations and scripts that integrate with your dotfiles.

## Setup

The `setup.sh` script in this directory will:

1. Install Raspberry Pi specific packages
2. Set up a Python virtual environment
3. Configure MQTT and Node-RED
4. Create useful aliases and functions
5. Set up project directories

## Usage

### Initial Setup

When setting up a new Raspberry Pi:

1. First install your dotfiles:
   ```bash
   git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ```

2. Then run the Raspberry Pi specific setup:
   ```bash
   cd ~/dotfiles/raspberry-pi
   ./setup.sh
   ```

### Headless Setup

For headless setup (without monitor/keyboard):

1. Flash Raspberry Pi OS to your MicroSD card
2. Before ejecting, create these files on the boot partition:
   - Empty file named `ssh` to enable SSH
   - `wpa_supplicant.conf` with your WiFi credentials:
     ```
     country=US
     ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
     update_config=1
     
     network={
         ssid="YOUR_WIFI_NAME"
         psk="YOUR_WIFI_PASSWORD"
         key_mgmt=WPA-PSK
     }
     ```

3. Insert the card, power on the Pi, and SSH in
4. Clone your dotfiles and run the setup scripts

## Configuration Files

- `config.txt` - Settings to add to `/boot/config.txt`
- `bashrc` - Raspberry Pi specific bash configuration

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
