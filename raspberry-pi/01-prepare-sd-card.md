# Step 1: Prepare the microSD Card

Before you can set up your Raspberry Pi with our optimized configurations, you'll need to prepare a microSD card with the Raspberry Pi OS.

## Requirements

- A microSD card (16GB minimum, 32GB or larger recommended)
- A computer with a microSD card reader
- Internet connection to download the necessary software

## Security Considerations

If you're concerned about connecting unknown USB devices directly to your system, consider these isolation methods:

```bash
# Option 1: Use a virtual machine with USB passthrough
# This isolates the device from your host system
# In VirtualBox: Devices > USB > Select your card reader
# In VMware: VM > Removable Devices > Select your card reader

# Option 2: Use a dedicated Raspberry Pi as an "air-gapped" SD writer
# Flash SD cards from a dedicated Pi that's not connected to your main system

# Option 3: Use a live Linux USB boot environment
# Boot from a trusted USB drive to create a temporary environment
# specifically for SD card operations
```

For maximum security, consider using a dedicated system or live Linux USB boot specifically for SD card operations.

## Command Line Approach

### 1. Insert your microSD card into your computer

```bash
# After inserting the card, identify it with:
lsblk -p

# Look for your SD card device (typically /dev/sdX or /dev/mmcblk0)
# Example output:
# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# /dev/sda      8:0    0  512G  0 disk 
# └─/dev/sda1   8:1    0  512G  0 part /
# /dev/sdb      8:16   1   32G  0 disk        # <-- This is likely your SD card
# └─/dev/sdb1   8:17   1   32G  0 part
```

### 2. Download Raspberry Pi OS image

```bash
# Create a directory for the image
mkdir -p ~/Downloads/raspberry-pi

# Download the latest Raspberry Pi OS (64-bit) image
wget -O ~/Downloads/raspberry-pi/raspios.img.xz https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64.img.xz

# For 32-bit version (for older Pi models), use:
# wget -O ~/Downloads/raspberry-pi/raspios.img.xz https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf.img.xz
```

### 3. Extract the image

```bash
# Extract the downloaded image
unxz ~/Downloads/raspberry-pi/raspios.img.xz
```

### 4. Write the image to the SD card

```bash
# IMPORTANT: Replace sdX with your actual device (e.g., sdb, NOT sdb1)
# WARNING: Using the wrong device can result in data loss!
sudo dd if=~/Downloads/raspberry-pi/raspios.img of=/dev/sdX bs=4M conv=fsync status=progress
```

### 5. Configure the Raspberry Pi OS (Headless Setup)

After the image is written, the boot partition will be mounted automatically. If not:

```bash
# Find the mount point
lsblk -p

# Mount if needed (replace X with your device letter)
sudo mkdir -p /mnt/boot
sudo mount /dev/sdX1 /mnt/boot
```

#### Enable SSH:

```bash
# Create an empty ssh file to enable SSH
sudo touch /mnt/boot/ssh
```

#### Configure WiFi (if needed):

```bash
# Create wpa_supplicant.conf file
cat << EOF | sudo tee /mnt/boot/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YOUR_WIFI_SSID"
    psk="YOUR_WIFI_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
```

#### Set hostname (optional):

```bash
# Create or edit the hostname file
echo "raspberrypi" | sudo tee /mnt/boot/hostname
```

### 6. Safely eject the SD card

```bash
# Sync to ensure all writes are complete
sync

# Unmount all partitions of the SD card
sudo umount /dev/sdX1
sudo umount /dev/sdX2 2>/dev/null || true

# Optional: Use eject command if available
sudo eject /dev/sdX
```

## GUI Alternative (Raspberry Pi Imager)

If you prefer a graphical interface:

```bash
# Install Raspberry Pi Imager
# Ubuntu/Debian:
sudo apt install rpi-imager

# Arch Linux:
sudo pacman -S rpi-imager

# Launch the application
rpi-imager
```

Then follow the on-screen instructions to:
1. Choose OS (Raspberry Pi OS 64-bit recommended for Pi 3/4/5)
2. Choose Storage (select your SD card)
3. Configure advanced options (⚙️) for hostname, SSH, WiFi, etc.
4. Write the image

## Next Steps

Your microSD card is now ready! Proceed to [Step 2: Hardware Setup](02-hardware-setup.md) to continue setting up your Raspberry Pi.

## Troubleshooting

```bash
# Check if your SD card is recognized
lsblk -p

# Verify the SD card is properly formatted
sudo fdisk -l /dev/sdX

# Check for bad blocks on the SD card
sudo badblocks -s -v /dev/sdX
```

- **Write Failed**: Check for write protection switch on the SD adapter
- **Verification Failed**: The card may be counterfeit or damaged
- **Can't Find SD Card**: Run `dmesg | tail` after inserting to see detection messages
