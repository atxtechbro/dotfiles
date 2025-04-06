#!/bin/bash
# Arch Linux Post-Installation Setup for ThinkPad T400
# OS-specific configuration (extends universal dotfiles setup)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Arch Linux post-installation setup...${NC}"

# Install git first if it's not already installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Installing git...${NC}"
    sudo pacman -S --needed --noconfirm git
fi

# First run the universal setup script
echo -e "${YELLOW}Running universal setup script...${NC}"
# Make sure we're in the dotfiles directory
cd "$(dirname "$0")"
./setup.sh

# Install additional Arch-specific packages
echo -e "${YELLOW}Installing additional Arch-specific packages...${NC}"
sudo pacman -S --needed --noconfirm \
    bash-completion \
    zip \
    unzip \
    openssh \
    rsync \
    tree \
    fzf \
    ripgrep \
    fd \
    ncdu \
    ranger

# ThinkPad T400 specific optimizations
echo -e "${YELLOW}Applying ThinkPad T400 optimizations...${NC}"

# CPU frequency scaling for better battery life
sudo pacman -S --needed --noconfirm cpupower
sudo systemctl enable cpupower
sudo sed -i 's/#governor=.*/governor="powersave"/' /etc/default/cpupower

# Enable audio
sudo pacman -S --needed --noconfirm alsa-utils
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute

# Setup console font for better readability
echo "FONT=ter-v16n" | sudo tee /etc/vconsole.conf
sudo pacman -S --needed --noconfirm terminus-font

# Install and configure a simple terminal-based browser
sudo pacman -S --needed --noconfirm w3m

# Setup a simple firewall
sudo pacman -S --needed --noconfirm ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

echo -e "${GREEN}Arch Linux post-installation setup complete!${NC}"
echo -e "${BLUE}Enjoy your optimized ThinkPad T400 environment!${NC}"
