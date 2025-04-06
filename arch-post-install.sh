#!/bin/bash
# Arch Linux Post-Installation Setup for ThinkPad T400
# OS-specific configuration (extends universal dotfiles setup)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting post-installation setup...${NC}"

# Install git first to clone dotfiles repository
echo -e "${YELLOW}Installing git...${NC}"
sudo pacman -S --needed --noconfirm git

# Clone dotfiles repository if it doesn't exist
if [ ! -d ~/dotfiles ]; then
    echo -e "${YELLOW}Cloning dotfiles repository...${NC}"
    git clone https://github.com/atxtechbro/dotfiles.git ~/dotfiles
    echo -e "${GREEN}Dotfiles repository cloned successfully!${NC}"
else
    echo -e "${BLUE}Dotfiles repository already exists, updating...${NC}"
    cd ~/dotfiles
    git pull
fi

# Install terminal-focused packages
echo -e "${YELLOW}Installing terminal utilities...${NC}"
sudo pacman -S --needed --noconfirm \
    tmux \
    neovim \
    bash-completion \
    wget \
    curl \
    zip \
    unzip \
    htop \
    jq \
    openssh \
    rsync \
    tree \
    fzf \
    ripgrep \
    fd \
    ncdu \
    ranger

# Setup dotfiles
echo -e "${YELLOW}Setting up dotfiles...${NC}"
mkdir -p ~/.config/nvim

# Create symlinks
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/.bash_exports ~/.bash_exports
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# Create secrets file from template
if [ -f ~/dotfiles/.bash_secrets.example ] && [ ! -f ~/.bash_secrets ]; then
    cp ~/dotfiles/.bash_secrets.example ~/.bash_secrets
    chmod 600 ~/.bash_secrets
    echo -e "${YELLOW}Created ~/.bash_secrets from template. Edit it to add your secrets.${NC}"
fi

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

# Apply bash configuration immediately
echo -e "${YELLOW}Applying bash configuration...${NC}"
source ~/.bashrc

echo -e "${GREEN}Post-installation setup complete!${NC}"
echo -e "${YELLOW}Your dotfiles have been set up and configured.${NC}"
echo -e "${BLUE}Enjoy your new Arch Linux environment!${NC}"
