# Arch Linux Minimal Setup for ThinkPad T400

This guide provides instructions for installing a minimal, terminal-only Arch Linux setup on a ThinkPad T400. The installation is optimized for older hardware while maintaining a functional and efficient system.

## Installation Process

### 1. Boot from Arch Linux ISO

Boot your ThinkPad T400 from the Arch Linux installation media.

### 2. Connect to the Internet

We assume you're using WiFi:
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <your_wifi_name>
# Enter password when prompted
exit
```

Verify connection:
```bash
ping -c 3 archlinux.org
```

### 3. Download the Installation Script

```bash
# Download the installation script using curl
curl -L https://raw.githubusercontent.com/atxtechbro/dotfiles/feature/arch-minimal/arch-install.sh -o /tmp/arch-install.sh
chmod +x /tmp/arch-install.sh
```

### 4. Run the Installation Script

```bash
cd /tmp
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

3. **Installation**: The script will install the base system and configure it for your ThinkPad T400

Follow the prompts to complete the installation.

### 5. After Rebooting

Log in with your user credentials and run the post-installation script:

```bash
# Connect to WiFi first
sudo iwctl
station wlan0 connect <your_wifi_name>
# Enter password when prompted
exit

# Download the post-installation script
curl -L https://raw.githubusercontent.com/atxtechbro/dotfiles/feature/arch-minimal/arch-post-install.sh -o ~/arch-post-install.sh
chmod +x ~/arch-post-install.sh

# Run the post-installation script
./arch-post-install.sh
```

## Key Features

- **Minimal Installation**: Only essential packages are installed
- **Terminal-focused**: No graphical environment, perfect for older hardware
- **Power Optimized**: Includes ThinkPad-specific optimizations for better battery life
- **Dotfiles Integration**: Automatically sets up your configuration files

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

## Customization

The minimal setup provides a solid foundation. You can further customize by:

1. Installing additional terminal utilities
2. Configuring your dotfiles
3. Setting up a terminal-based workflow with tmux and neovim

## Resources

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [ThinkWiki T400 Page](https://www.thinkwiki.org/wiki/Category:T400)
