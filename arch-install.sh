#!/bin/bash
# Arch Linux Minimal Installation Script for ThinkPad T400
# Created for dotfiles repository

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${GREEN}[LOG]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run as root"
fi

# Verify boot mode (BIOS/UEFI)
log "Checking boot mode..."
if [ -d "/sys/firmware/efi/efivars" ]; then
    BOOT_MODE="UEFI"
    log "Detected UEFI boot mode"
else
    BOOT_MODE="BIOS"
    log "Detected BIOS boot mode (Legacy)"
fi

# Update system clock
log "Updating system clock..."
timedatectl set-ntp true

# Disk setup
log "Starting disk setup..."
echo -e "${YELLOW}Available disks:${NC}"
lsblk
echo ""
read -p "Enter the disk to install Arch Linux (e.g., /dev/sda): " DISK
if [ ! -b "$DISK" ]; then
    error "Invalid disk: $DISK"
fi

# Confirm disk selection
echo -e "${RED}WARNING: This will erase all data on $DISK${NC}"
read -p "Are you sure you want to continue? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    error "Installation aborted by user"
fi

# Partition the disk
log "Partitioning disk $DISK..."
if [ "$BOOT_MODE" = "UEFI" ]; then
    # UEFI partitioning
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
    parted -s "$DISK" set 1 boot on
    parted -s "$DISK" mkpart primary linux-swap 513MiB 2561MiB
    parted -s "$DISK" mkpart primary ext4 2561MiB 100%
    
    BOOT_PART="${DISK}1"
    SWAP_PART="${DISK}2"
    ROOT_PART="${DISK}3"
else
    # BIOS partitioning
    parted -s "$DISK" mklabel msdos
    parted -s "$DISK" mkpart primary linux-swap 1MiB 2049MiB
    parted -s "$DISK" mkpart primary ext4 2049MiB 100%
    parted -s "$DISK" set 2 boot on
    
    SWAP_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi

# Format partitions
log "Formatting partitions..."
if [ "$BOOT_MODE" = "UEFI" ]; then
    mkfs.fat -F32 "$BOOT_PART"
fi
mkswap "$SWAP_PART"
mkfs.ext4 "$ROOT_PART"

# Mount partitions
log "Mounting partitions..."
mount "$ROOT_PART" /mnt
if [ "$BOOT_MODE" = "UEFI" ]; then
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
fi
swapon "$SWAP_PART"

# Install essential packages
log "Installing essential packages..."
pacstrap /mnt base linux linux-firmware base-devel

# Install additional minimal packages
log "Installing additional minimal packages..."
pacstrap /mnt \
    dhcpcd \
    iwd \
    sudo \
    vim \
    man-db \
    man-pages \
    git \
    tmux \
    htop \
    neofetch

# Generate fstab
log "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot setup script
log "Creating chroot setup script..."
cat > /mnt/arch-chroot-setup.sh << 'EOF'
#!/bin/bash
set -e

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network configuration
read -p "Enter hostname: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << END
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
END

# Set root password
echo "Setting root password..."
passwd

# Create a user
read -p "Enter username: " USERNAME
useradd -m -G wheel "$USERNAME"
echo "Setting password for $USERNAME..."
passwd "$USERNAME"

# Configure sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

# Enable services
systemctl enable dhcpcd
systemctl enable iwd

# Install bootloader
if [ -d "/sys/firmware/efi" ]; then
    # UEFI boot
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    # BIOS boot
    pacman -S --noconfirm grub
    read -p "Enter disk for GRUB (e.g., /dev/sda): " DISK
    grub-install --target=i386-pc "$DISK"
fi
grub-mkconfig -o /boot/grub/grub.cfg

# ThinkPad specific packages
pacman -S --noconfirm acpi_call tlp

# Enable TLP for better battery life
systemctl enable tlp

# Create dotfiles directory
mkdir -p /home/$USERNAME/dotfiles

# Setup complete
echo "Chroot setup complete!"
EOF

chmod +x /mnt/arch-chroot-setup.sh

# Enter chroot
log "Entering chroot environment to complete setup..."
arch-chroot /mnt /arch-chroot-setup.sh

# Clean up
rm /mnt/arch-chroot-setup.sh

# Unmount partitions
log "Unmounting partitions..."
umount -R /mnt

log "Installation complete! You can now reboot into your new Arch Linux system."
log "After reboot, connect to wifi with: iwctl"
log "Then clone your dotfiles with: git clone https://github.com/yourusername/dotfiles.git ~/dotfiles"
