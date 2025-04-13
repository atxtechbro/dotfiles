# Headless Raspberry Pi Setup

These files are used to set up a Raspberry Pi in headless mode (without keyboard/monitor).

## Instructions

1. Flash Raspberry Pi OS to your MicroSD card using Raspberry Pi Imager
2. Before ejecting the card, copy these files to the boot partition:
   - `ssh` (empty file to enable SSH)
   - `wpa_supplicant.conf` (edit with your WiFi credentials)

3. Insert the card into your Pi and power it on
4. Find your Pi's IP address from your router
5. SSH into your Pi: `ssh pi@your-pi-ip-address`
6. Clone your dotfiles repository and run the setup script:
   ```bash
   git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ```

The setup script will detect that it's running on a Raspberry Pi and automatically run the Pi-specific setup.
