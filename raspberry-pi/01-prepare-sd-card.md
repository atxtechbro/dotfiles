# Step 1: Prepare the microSD Card

Before you can set up your Raspberry Pi with our optimized configurations, you'll need to prepare a microSD card with the Raspberry Pi OS.

## Requirements

- A microSD card (16GB minimum, 32GB or larger recommended)
- A computer with a microSD card reader
- Internet connection to download the necessary software

## Security Considerations

If you're concerned about connecting unknown USB devices directly to your system, consider using USB port power management for controlled access:

```bash
# Use USB port power management for controlled access
# This lets you examine a device before allowing it full system access

# First, identify your USB ports (before connecting the device)
ls /sys/bus/usb/devices/

# Disable a specific USB port (replace X-Y with bus-port format, e.g., 5-2)
sudo sh -c 'echo 0 > /sys/bus/usb/devices/5-2/authorized'

# Now connect your device to that port - it won't be activated yet
# Check the kernel messages to see device details without activating it:
sudo dmesg | tail -20
# This shows recent kernel messages, including USB device information
# Look for entries like "new USB device found" with vendor/product IDs

# Example output from a CanaKit USB microSD card reader:
# [35076.589179] usb 5-2: New USB device found, idVendor=14cd, idProduct=1212, bcdDevice= 1.00
# [35076.589185] usb 5-2: New USB device strings: Mfr=1, Product=3, SerialNumber=2
# [35076.589188] usb 5-2: Product: Mass Storage Device
# [35076.589190] usb 5-2: Manufacturer: Generic
# [35076.589193] usb 5-2: SerialNumber: 121220160204
# Note: Many kit-provided card readers show generic identifiers like this

# Take a snapshot of current block devices before authorizing
lsblk -p > before.txt

# When you're ready to use it (after verifying it's safe):
sudo sh -c 'echo 1 > /sys/bus/usb/devices/5-2/authorized'

# See exactly what block devices were added by the USB device
lsblk -p > after.txt
diff before.txt after.txt
# Example output:
# > /dev/sda                      8:0    1 119.4G  0 disk
# > ├─/dev/sda1                   8:1    1   512M  0 part  /media/mstack/bootfs
# > └─/dev/sda2                   8:2    1     5G  0 part  /media/mstack/rootfs
```

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

### 2. Download Raspberry Pi OS Lite image

```bash
# Create a directory for the image
mkdir -p ~/Downloads/raspberry-pi

# Download the latest Raspberry Pi OS Lite (64-bit) image
# This is a minimal version perfect for headless setups (no desktop environment)
wget -O ~/Downloads/raspberry-pi/raspios-lite.img.xz https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-11-19/2024-11-19-raspios-bookworm-arm64-lite.img.xz

# For 32-bit version (for older Pi models), use:
# wget -O ~/Downloads/raspberry-pi/raspios-lite.img.xz https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2024-11-19/2024-11-19-raspios-bookworm-armhf-lite.img.xz
```

> **Note:** We're using Raspberry Pi OS Lite since this is for a headless setup. This version:
> - Is smaller than the desktop version (~2.8GB vs ~4GB for standard as of November 2024)
> - Uses fewer system resources
> - Perfect for server applications
> - Has no desktop environment (command-line only)

### 3. Extract the image

```bash
# Option 1: Standard extraction (no progress bar)
unxz ~/Downloads/raspberry-pi/raspios-lite.img.xz

# Option 2: Extract with progress bar using pv (pipe viewer)
# First install pv if you don't have it: sudo apt install pv
pv ~/Downloads/raspberry-pi/raspios-lite.img.xz | xz -dc > ~/Downloads/raspberry-pi/raspios-lite.img
```

### 4. Write the image to the SD card

```bash
# IMPORTANT: First identify your SD card device using the before/after comparison
lsblk -p > before.txt
# Now insert your SD card if you haven't already
lsblk -p > after.txt
diff before.txt after.txt
# Example output:
# > /dev/sda                      8:0    1 119.4G  0 disk
# > ├─/dev/sda1                   8:1    1   512M  0 part  /media/user/bootfs
# > └─/dev/sda2                   8:2    1     5G  0 part  /media/user/rootfs

# From the output above, we can see the device is /dev/sda (NOT sda1 or sda2)
# Now write the image using the device name from your diff output:
sudo dd if=~/Downloads/raspberry-pi/raspios-lite.img of=/dev/sda bs=4M conv=fsync status=progress
```

⚠️ **WARNING**: Double-check your device name! Using the wrong device can result in data loss. The device should be the one that appeared in your diff output (like `/dev/sda` in the example).

> **Note on write time**: The November 2024 Lite version is approximately 2.8GB in size. Depending on your SD card speed, writing may take 5-15 minutes. The `status=progress` flag will show you the current progress.

### 5. Configure the Raspberry Pi OS (Headless Setup)

After writing the image, check if the boot partition was mounted automatically:

```bash
# Check if the boot partition is mounted
lsblk -p | grep sda1

# Example output if mounted:
# /dev/sda1   8:1    1  512M  0 part  /media/user/bootfs
```

Use the actual mount point from your output (like `/media/user/bootfs`) for the following steps. If you don't see a mount point, mount it manually:

```bash
# Only if not already mounted:
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot
# Then use /mnt/boot as your mount point in the following steps
```

#### Enable SSH:

```bash
# Create an empty ssh file to enable SSH
# Use your actual boot partition mount point (from the lsblk command above)
sudo touch /media/user/bootfs/ssh

# If you mounted manually, use:
# sudo touch /mnt/boot/ssh
```

#### Configure WiFi (if needed):

```bash
# Create wpa_supplicant.conf file
# Use your actual boot partition mount point (from the lsblk command above)
cat << EOF | sudo tee /media/user/bootfs/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YOUR_WIFI_SSID"
    psk="YOUR_WIFI_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF

# If you mounted manually, use:
# cat << EOF | sudo tee /mnt/boot/wpa_supplicant.conf
# ...
```

#### Set hostname (optional):

```bash
# Create or edit the hostname file
# Use your actual boot partition mount point (from the lsblk command above)
echo "raspberrypi" | sudo tee /media/user/bootfs/hostname

# If you mounted manually, use:
# echo "raspberrypi" | sudo tee /mnt/boot/hostname
```

### 6. Safely eject the SD card

```bash
# Sync to ensure all writes are complete
sync

# Unmount all partitions of the SD card
# Use the actual device name from your system (e.g., sda1, sda2)
sudo umount /dev/sda1
sudo umount /dev/sda2 2>/dev/null || true

# Optional: Use eject command if available
sudo eject /dev/sda
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
