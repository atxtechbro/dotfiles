# Headless Raspberry Pi Setup

These files are used to set up a Raspberry Pi in headless mode (without keyboard/monitor).

## Instructions

1. Flash Raspberry Pi OS to your MicroSD card using the included script:
   ```bash
   # Show available devices
   lsblk
   
   # Flash with WiFi and custom hostname
   cd ~/dotfiles/raspberry-pi
   ./flash-sd.sh --device /dev/sdX --wifi YourNetwork:YourPassword --hostname mypi
   ```
   
   The script will automatically configure WiFi and SSH for headless setup.

2. Alternatively, if flashing manually, copy these files to the boot partition:
   - `ssh` (empty file to enable SSH)
   - `wpa_supplicant.conf` (edit with your WiFi credentials)

3. Insert the card into your Pi and power it on
4. Find your Pi's IP address from your router or use hostname: `ping mypi.local`
5. SSH into your Pi: `ssh pi@mypi.local` or `ssh pi@your-pi-ip-address`
6. Clone your dotfiles repository and run the setup script:
   ```bash
   git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ```

The setup script will detect that it's running on a Raspberry Pi and automatically run the Pi-specific setup.
