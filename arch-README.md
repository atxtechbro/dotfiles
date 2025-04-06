# Arch Linux Minimal Setup for ThinkPad T400

This guide provides instructions for installing a minimal, terminal-only Arch Linux setup on a ThinkPad T400. The installation is optimized for older hardware while maintaining a functional and efficient system.

## Installation Process

### 1. Boot from Arch Linux ISO

Boot your ThinkPad T400 from the Arch Linux installation media.

### 2. Connect to the Internet

If using WiFi:
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect SSID
# Enter password when prompted
exit
```

Verify connection:
```bash
ping -c 3 archlinux.org
```

### 3. Download the Installation Script

```bash
# If git is available on the live environment
git clone https://github.com/yourusername/dotfiles.git /tmp/dotfiles
cd /tmp/dotfiles
git checkout feature/arch-minimal

# If git is not available, use curl
curl -L https://raw.githubusercontent.com/yourusername/dotfiles/feature/arch-minimal/arch-install.sh -o /tmp/arch-install.sh
chmod +x /tmp/arch-install.sh
```

### 4. Run the Installation Script

```bash
cd /tmp
./arch-install.sh
```

Follow the prompts to complete the installation.

### 5. After Rebooting

Log in with your user credentials and run the post-installation script:

```bash
# Connect to WiFi first
sudo iwctl
station wlan0 connect SSID
# Enter password when prompted
exit

# Clone your dotfiles repository if not already done
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
git checkout feature/arch-minimal

# Run the post-installation script
chmod +x ./arch-post-install.sh
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
