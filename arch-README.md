# Arch Linux Minimal Setup for ThinkPad T400

This guide provides instructions for installing a minimal, terminal-only Arch Linux setup on a ThinkPad T400. The installation is optimized for older hardware while maintaining a functional and efficient system.

## Prerequisites

This guide assumes you have:
- Booted your ThinkPad T400 from the USB drive (press F12 during startup to access the boot menu) with Arch Linux ISO image
- Basic familiarity with Linux command line

## Installation Process

### 1. Connect to the Internet

We assume you're using WiFi:
```bash
iwctl
station wlan0 get-networks
station wlan0 connect <your_wifi_name>
# Enter your WiFi password when prompted (or press Enter if network is open)
exit
```

Verify connection:
```bash
ping -c 3 google.com
```

### 3. Download the Installation Script

```bash
# Download the installation script using curl
curl -L https://raw.githubusercontent.com/atxtechbro/dotfiles/feature/combined-setup/arch-install.sh -o /tmp/arch-install.sh
```

### 4. Run the Installation Script

```bash
cd /tmp
./arch-install.sh
```

The installation script will guide you through the process. Here's what to expect:

1. **Disk Selection**: The script will display a list of available disks and prompt you to choose one for installation.
   ```
   Available disks:
   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   sda      8:0    0 119.2G  0 disk 
   ├─sda1   8:1    0   512M  0 part 
   └─sda2   8:2    0 118.7G  0 part 
   
   Enter the disk to install Arch Linux (e.g., /dev/sda): 
   ```
   - Enter the full path (e.g., `/dev/sda`) of the disk you want to use
   - The script will ask for confirmation before erasing the disk

2. **System Configuration**: You'll be prompted for several important settings in this order:
   
   a. **Hostname**: This is your computer's network name (not your username)
   ```
   Enter hostname: 
   ```
   - Example: "thinkpad-t400" or "arch-machine"
   
   b. **Root Password**: You'll need to set the administrator password
   ```
   Setting root password...
   ```
   - You'll be asked to enter this password twice
   - This is for the "root" superuser account (like Administrator in Windows)
   - You'll use this password when logging in as root or when using the `su` command
   
   c. **User Account**: Then create your personal user account
   ```
   Enter username: 
   ```
   - This is your regular login name, different from the hostname
   
   d. **User Password**: Set a password for your user account
   ```
   Setting password for username...
   ```
   - You'll be asked to enter this password twice
   - This is the password you'll use for daily logins and when using `sudo` commands
   - This is separate from the root password and should be different for security
   
   e. **GRUB Disk Selection**: For BIOS systems (like the ThinkPad T400), you'll be asked to select the disk again
   ```
   Enter disk for GRUB (e.g., /dev/sda):
   ```
   - Enter the same disk you selected earlier (e.g., `/dev/sda`)
   - This second prompt is specifically for installing the bootloader to the disk's Master Boot Record (MBR)
   - This step is only needed for BIOS/Legacy boot systems (not for UEFI systems)

3. **Installation**: The script will install the base system and configure it for your ThinkPad T400

Follow the prompts to complete the installation. When the installation is finished, you'll see a message indicating it's complete.

### 5. Reboot into Your New System

Once the installation is complete, reboot your system and remove the USB drive:

```bash
# Exit the installation environment and reboot
reboot
```

When the system restarts, remove the USB drive during the boot process so that your computer boots from the newly installed system.

### 6. After Rebooting

Log in with your user credentials (the username and password you created during installation). Now we'll pull in your personalized environment:

```bash
# Connect to WiFi first
sudo iwctl
station wlan0 connect <your_wifi_name>
# Enter your WiFi password when prompted (or press Enter if network is open)
exit

# Download and run the setup script directly
curl -fsSL https://raw.githubusercontent.com/atxtechbro/dotfiles/feature/combined-setup/setup.sh | bash

# After setup completes, your familiar environment will be ready with all your personal configurations
```

## ThinkPad T400 Specific Optimizations

After running the setup script, you may want to apply these ThinkPad-specific optimizations:

### CPU Frequency Scaling for Better Battery Life
```bash
sudo pacman -S --needed --noconfirm cpupower
sudo systemctl enable cpupower
sudo sed -i 's/#governor=.*/governor="powersave"/' /etc/default/cpupower
```

### Audio Configuration
```bash
sudo pacman -S --needed --noconfirm alsa-utils
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute
```

### Console Font for Better Readability
```bash
sudo pacman -S --needed --noconfirm terminus-font
echo "FONT=ter-v16n" | sudo tee /etc/vconsole.conf
```

### Simple Firewall Setup
```bash
sudo pacman -S --needed --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

## Key Features

- **Minimal Installation**: Only essential packages are installed
- **Terminal-focused**: No graphical environment, perfect for older hardware
- **Power Optimized**: Includes ThinkPad-specific optimizations for better battery life
- **Complete Dotfiles Integration**: Automatically sets up all configuration files
- **Ready to Use**: Your familiar environment is immediately available after installation

## Important Note on Configuration

After running the setup script and reloading your `.bashrc` file:
1. All your personal configurations from the dotfiles repository are automatically applied
2. Any changes you make to files in the dotfiles repository will be reflected in your environment
3. Your secrets are securely stored in `~/.bash_secrets` (not tracked in git)

## Troubleshooting

### WiFi Issues
If you have trouble connecting to WiFi after installation:
```bash
sudo systemctl start iwd
sudo systemctl enable iwd
sudo systemctl start dhcpcd
sudo systemctl enable dhcpcd
```

### Boot Issues
If the system fails to boot:
1. Boot from the installation media
2. Mount your partitions: `mount /dev/sdaX /mnt`
3. Chroot into the system: `arch-chroot /mnt`
4. Reinstall the bootloader or fix configuration issues

## Resources

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [ThinkWiki T400 Page](https://www.thinkwiki.org/wiki/Category:T400)
