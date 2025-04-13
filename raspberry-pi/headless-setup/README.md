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

2. Insert the card into your Pi and power it on

3. Connect to your Pi via SSH:
   ```bash
   # Using hostname (if your router supports mDNS)
   ssh pi@mypi.local
   
   # Or using IP address (find it from your router)
   ssh pi@192.168.1.xxx
   ```

4. Clone your dotfiles repository and run the setup script:
   ```bash
   git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./setup.sh
   ```

The setup script will detect that it's running on a Raspberry Pi and automatically run the Pi-specific setup.
