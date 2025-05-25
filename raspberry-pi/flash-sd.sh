#!/bin/bash
# Script to flash Raspberry Pi OS to MicroSD card for headless setup
# Part of dotfiles/raspberry-pi

set -e  # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    echo -e "${BLUE}Raspberry Pi OS SD Card Flashing Script${NC}"
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0 [options]"
    echo -e ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -d, --device DEVICE    Specify the device to flash to (e.g., /dev/sdb)"
    echo -e "  -i, --image IMAGE      Specify the image file to use (default: download latest)"
    echo -e "  -w, --wifi SSID:PASS   Configure WiFi (format: SSID:password)"
    echo -e "  -n, --hostname NAME    Set hostname (default: raspberrypi)"
    echo -e "  -s, --ssh              Enable SSH (default: enabled)"
    echo -e "  -h, --help             Show this help message"
    echo -e ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 --device /dev/sdb"
    echo -e "  $0 --device /dev/sdb --wifi MyNetwork:MyPassword --hostname mypi"
    echo -e "  $0 --device /dev/sdb --image ~/Downloads/raspios.img.xz"
    echo -e ""
}

# Default values
DOWNLOAD_IMAGE=true
ENABLE_SSH=true
HOSTNAME="raspberrypi"
WIFI_SSID=""
WIFI_PASS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -i|--image)
            IMAGE_FILE="$2"
            DOWNLOAD_IMAGE=false
            shift 2
            ;;
        -w|--wifi)
            WIFI_CONFIG="$2"
            WIFI_SSID=$(echo $WIFI_CONFIG | cut -d: -f1)
            WIFI_PASS=$(echo $WIFI_CONFIG | cut -d: -f2-)
            shift 2
            ;;
        -n|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -s|--ssh)
            ENABLE_SSH=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Check if device is specified
if [ -z "$DEVICE" ]; then
    echo -e "${RED}Error: No device specified.${NC}"
    echo -e "${YELLOW}Available devices:${NC}"
    lsblk -p -o NAME,SIZE,MODEL,VENDOR
    echo -e "${YELLOW}Use --device to specify the target device.${NC}"
    exit 1
fi

# Check if device exists
if [ ! -b "$DEVICE" ]; then
    echo -e "${RED}Error: Device $DEVICE does not exist or is not a block device.${NC}"
    exit 1
fi

# Create a temporary directory
TMP_DIR=$(mktemp -d)
echo -e "${BLUE}Created temporary directory: $TMP_DIR${NC}"

# Clean up on exit
cleanup() {
    echo -e "${BLUE}Cleaning up...${NC}"
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Download the latest Raspberry Pi OS image if needed
if [ "$DOWNLOAD_IMAGE" = true ]; then
    echo -e "${YELLOW}Downloading latest Raspberry Pi OS (64-bit)...${NC}"
    
    # Get the latest image URL
    LATEST_URL=$(curl -s https://downloads.raspberrypi.org/raspios_arm64_latest | grep -o 'https://.*\.img\.xz')
    
    if [ -z "$LATEST_URL" ]; then
        echo -e "${RED}Error: Could not find latest Raspberry Pi OS image URL.${NC}"
        exit 1
    fi
    
    IMAGE_FILE="$TMP_DIR/raspios.img.xz"
    echo -e "${BLUE}Downloading from: $LATEST_URL${NC}"
    wget -O "$IMAGE_FILE" "$LATEST_URL" --progress=bar:force
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Download failed.${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}Using provided image: $IMAGE_FILE${NC}"
    
    # Check if the image file exists
    if [ ! -f "$IMAGE_FILE" ]; then
        echo -e "${RED}Error: Image file $IMAGE_FILE does not exist.${NC}"
        exit 1
    fi
fi

# Confirm with the user
echo -e "${RED}WARNING: This will erase all data on $DEVICE!${NC}"
echo -e "${YELLOW}Device details:${NC}"
lsblk -p -o NAME,SIZE,MODEL,VENDOR "$DEVICE"
echo -e "${YELLOW}Image file: $IMAGE_FILE${NC}"
echo -e "${YELLOW}Hostname: $HOSTNAME${NC}"
echo -e "${YELLOW}SSH enabled: $ENABLE_SSH${NC}"

if [ ! -z "$WIFI_SSID" ]; then
    echo -e "${YELLOW}WiFi: $WIFI_SSID${NC}"
fi

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Operation cancelled.${NC}"
    exit 1
fi

# Flash the image
echo -e "${YELLOW}Flashing image to $DEVICE...${NC}"
echo -e "${BLUE}This may take several minutes. Please be patient.${NC}"

if [[ "$IMAGE_FILE" == *.xz ]]; then
    # For .xz compressed images
    xzcat "$IMAGE_FILE" | sudo dd of="$DEVICE" bs=4M status=progress conv=fsync
else
    # For uncompressed images
    sudo dd if="$IMAGE_FILE" of="$DEVICE" bs=4M status=progress conv=fsync
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Flashing failed.${NC}"
    exit 1
fi

echo -e "${GREEN}Image flashed successfully!${NC}"

# Sync to ensure all writes are complete
echo -e "${YELLOW}Syncing...${NC}"
sync

# Set up for headless operation
echo -e "${YELLOW}Setting up for headless operation...${NC}"

# Create mount points
BOOT_MOUNT="$TMP_DIR/boot"
ROOT_MOUNT="$TMP_DIR/rootfs"
mkdir -p "$BOOT_MOUNT" "$ROOT_MOUNT"

# Wait a moment for the kernel to recognize the new partitions
sleep 2

# Find the boot partition
BOOT_PART="${DEVICE}1"
if [ ! -b "$BOOT_PART" ]; then
    # Try alternative naming schemes
    BOOT_PART="${DEVICE}p1"
    if [ ! -b "$BOOT_PART" ]; then
        echo -e "${RED}Error: Could not find boot partition.${NC}"
        exit 1
    fi
fi

# Mount the boot partition
echo -e "${BLUE}Mounting boot partition...${NC}"
sudo mount "$BOOT_PART" "$BOOT_MOUNT"

# Enable SSH
if [ "$ENABLE_SSH" = true ]; then
    echo -e "${BLUE}Enabling SSH...${NC}"
    sudo touch "$BOOT_MOUNT/ssh"
fi

# Configure WiFi if specified
if [ ! -z "$WIFI_SSID" ]; then
    echo -e "${BLUE}Configuring WiFi...${NC}"
    cat > "$TMP_DIR/wpa_supplicant.conf" << EOF
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASS"
    key_mgmt=WPA-PSK
}
EOF
    sudo cp "$TMP_DIR/wpa_supplicant.conf" "$BOOT_MOUNT/wpa_supplicant.conf"
fi

# Set hostname if different from default
if [ "$HOSTNAME" != "raspberrypi" ]; then
    echo -e "${BLUE}Setting hostname to $HOSTNAME...${NC}"
    echo "$HOSTNAME" | sudo tee "$BOOT_MOUNT/hostname" > /dev/null
    
    # Try to mount rootfs to update /etc/hostname and /etc/hosts
    ROOT_PART="${DEVICE}2"
    if [ ! -b "$ROOT_PART" ]; then
        ROOT_PART="${DEVICE}p2"
    fi
    
    if [ -b "$ROOT_PART" ]; then
        sudo mount "$ROOT_PART" "$ROOT_MOUNT"
        echo "$HOSTNAME" | sudo tee "$ROOT_MOUNT/etc/hostname" > /dev/null
        sudo sed -i "s/127.0.1.1.*raspberrypi/127.0.1.1\t$HOSTNAME/g" "$ROOT_MOUNT/etc/hosts"
        sudo umount "$ROOT_MOUNT"
    fi
fi

# Unmount the boot partition
sudo umount "$BOOT_MOUNT"

# Eject the device
echo -e "${YELLOW}Ejecting $DEVICE...${NC}"
sudo eject "$DEVICE"

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}You can now insert the MicroSD card into your Raspberry Pi.${NC}"
echo -e "${BLUE}The Pi will boot and connect to your WiFi network (if configured).${NC}"
echo -e "${BLUE}You can SSH into it using: ssh pi@$HOSTNAME.local${NC}"
echo -e "${YELLOW}Default username: pi${NC}"
echo -e "${YELLOW}Default password: raspberry${NC}"
echo -e "${RED}IMPORTANT: Change the default password immediately after first login!${NC}"
