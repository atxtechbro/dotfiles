#!/bin/bash
# Raspberry Pi Headless Setup Script
# Part of dotfiles/raspberry-pi

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

# Check if we're actually on a Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo &>/dev/null; then
    warn "This doesn't appear to be a Raspberry Pi."
    warn "Skipping Raspberry Pi specific setup."
    exit 0
fi

log "Setting up Raspberry Pi headless environment..."

# Check if running as root and get sudo if needed
if [ "$(id -u)" -ne 0 ]; then
    log "Some operations require root privileges. You may be prompted for your password."
fi

# Create project directories
log "Creating Raspberry Pi project directories..."
mkdir -p ~/projects/raspberry-pi/{src,config,scripts,data,logs,web}

# Install essential packages
log "Installing essential Raspberry Pi packages..."
sudo apt update
sudo apt install -y \
    git \
    curl \
    wget \
    tmux \
    htop \
    neofetch \
    jq

# Ask user which components to install
echo
log "Select components to install:"
echo "1) Minimal setup (recommended for headless servers)"
echo "2) Development environment (Python, GPIO libraries)"
echo "3) IoT environment (MQTT, Node-RED)"
echo "4) All components"
echo
read -r -p "Enter your choice (1-4): " CHOICE

case $CHOICE in
    1)
        INSTALL_MINIMAL=true
        INSTALL_DEV=false
        INSTALL_IOT=false
        ;;
    2)
        INSTALL_MINIMAL=true
        INSTALL_DEV=true
        INSTALL_IOT=false
        ;;
    3)
        INSTALL_MINIMAL=true
        INSTALL_DEV=false
        INSTALL_IOT=true
        ;;
    4)
        INSTALL_MINIMAL=true
        INSTALL_DEV=true
        INSTALL_IOT=true
        ;;
    *)
        warn "Invalid choice. Installing minimal setup only."
        INSTALL_MINIMAL=true
        INSTALL_DEV=false
        INSTALL_IOT=false
        ;;
esac

# Install minimal packages
if [ "$INSTALL_MINIMAL" = true ]; then
    log "Installing minimal packages..."
    sudo apt install -y \
        vim \
        python3 \
        python3-pip \
        i2c-tools
fi

# Install development packages
if [ "$INSTALL_DEV" = true ]; then
    log "Installing development packages..."
    sudo apt install -y \
        python3-venv \
        python3-dev \
        python3-rpi.gpio \
        python3-gpiozero \
        wiringpi \
        build-essential
        
    # Set up Python virtual environment
    log "Setting up Python virtual environment..."
    cd ~/projects/raspberry-pi
    python3 -m venv venv
    source venv/bin/activate
    
    # Install uv if not already installed
    if ! command -v uv >/dev/null 2>&1; then
        log "Installing uv package manager..."
        curl -Ls https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Install Python packages using uv
    log "Installing Python packages with uv..."
    uv pip install \
        flask \
        requests \
        gpiozero \
        RPi.GPIO \
        adafruit-blinka \
        python-dotenv
fi

# Install IoT packages
if [ "$INSTALL_IOT" = true ]; then
    log "Installing IoT packages..."
    sudo apt install -y \
        mosquitto \
        mosquitto-clients \
        node-red
        
    # Install Python MQTT client if dev environment is also installed
    if [ "$INSTALL_DEV" = true ]; then
        source ~/projects/raspberry-pi/venv/bin/activate
        uv pip install paho-mqtt
    fi
    
    # Configure MQTT broker for local connections only
    log "Configuring MQTT broker for security..."
    sudo bash -c 'cat > /etc/mosquitto/conf.d/local.conf << EOF
# Only listen on localhost by default for security
listener 1883 localhost

# Uncomment and modify these lines to allow remote connections
#listener 1883
#allow_anonymous false
#password_file /etc/mosquitto/passwd
EOF'

    # Enable and start MQTT broker
    log "Enabling MQTT broker service..."
    sudo systemctl enable mosquitto
    sudo systemctl restart mosquitto
    
    # Enable and start Node-RED
    log "Enabling Node-RED service..."
    sudo systemctl enable nodered.service
    sudo systemctl start nodered.service
fi

# Create Raspberry Pi specific configuration files
log "Creating Raspberry Pi configuration files..."

# Create .env file for project configuration
if [ "$INSTALL_DEV" = true ] || [ "$INSTALL_IOT" = true ]; then
    cat > ~/projects/raspberry-pi/.env << EOF
# Environment variables for Raspberry Pi project
PI_NAME=$(hostname)
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_TOPIC=home/$(hostname)
LOG_LEVEL=INFO
EOF
fi

# Create Raspberry Pi specific bash configuration
mkdir -p ~/dotfiles/raspberry-pi
cat > ~/dotfiles/raspberry-pi/bashrc << EOF
# Raspberry Pi specific aliases and functions
alias temp='vcgencmd measure_temp'
alias freq='vcgencmd measure_clock arm'
alias mem='free -h'
alias pitemp='echo "CPU temp: \$(vcgencmd measure_temp | cut -d= -f2)"'

# Function to control GPIO pins easily
gpio() {
    if [ "\$1" = "read" ]; then
        gpio -g read \$2
    elif [ "\$1" = "write" ]; then
        gpio -g write \$2 \$3
    elif [ "\$1" = "mode" ]; then
        gpio -g mode \$2 \$3
    else
        echo "Usage: gpio read|write|mode PIN [VALUE|MODE]"
    fi
}

# Add project directory to PATH
export PATH="\$HOME/projects/raspberry-pi/bin:\$PATH"

# Add uv to PATH if installed
if [ -d "\$HOME/.local/bin" ]; then
    export PATH="\$HOME/.local/bin:\$PATH"
fi

# Activate Python virtual environment if it exists
if [ -f "\$HOME/projects/raspberry-pi/venv/bin/activate" ]; then
    source "\$HOME/projects/raspberry-pi/venv/bin/activate"
fi
EOF

# Add Raspberry Pi specific configuration to .bashrc
if ! grep -q "source ~/dotfiles/raspberry-pi/bashrc" ~/.bashrc; then
    echo -e "\n# Source Raspberry Pi specific configuration" >> ~/.bashrc
    echo "source ~/dotfiles/raspberry-pi/bashrc" >> ~/.bashrc
fi

# Create a bin directory for scripts
mkdir -p ~/projects/raspberry-pi/bin

# Create a simple utility script
cat > ~/projects/raspberry-pi/bin/pisystem << 'EOF'
#!/bin/bash
# Simple system information script for Raspberry Pi

echo "=== Raspberry Pi System Information ==="
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I)"
echo "CPU Temperature: $(vcgencmd measure_temp | cut -d= -f2)"
echo "CPU Frequency: $(vcgencmd measure_clock arm | awk -F= '{print $2/1000000 " MHz"}')"
echo "Memory Usage: $(free -h | awk '/^Mem:/ {print $3 " of " $2 " used (" $3/$2*100 "%")')"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $3 " of " $2 " used (" $5 ")"}')"
echo "Uptime: $(uptime -p)"
echo "======================================="
EOF

chmod +x ~/projects/raspberry-pi/bin/pisystem

# Create a headless setup helper script
cat > ~/projects/raspberry-pi/bin/headless-setup << 'EOF'
#!/bin/bash
# Helper script for headless Raspberry Pi setup

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}"
    echo -e "${YELLOW}Try: sudo $(basename $0)${NC}"
    exit 1
fi

# Display current network configuration
echo -e "${BLUE}Current network configuration:${NC}"
hostname -I
ip route | grep default

# Configure static IP (optional)
echo
echo -e "${YELLOW}Would you like to configure a static IP address? (y/n)${NC}"
read -r CONFIGURE_STATIC_IP

if [[ "$CONFIGURE_STATIC_IP" =~ ^[Yy]$ ]]; then
    # Get current gateway and interface
    CURRENT_GATEWAY=$(ip route | grep default | awk '{print $3}')
    CURRENT_INTERFACE=$(ip route | grep default | awk '{print $5}')
    
    # Get user input
    echo -e "${YELLOW}Enter static IP address (e.g., 192.168.1.100):${NC}"
    read -r STATIC_IP
    
    echo -e "${YELLOW}Enter subnet mask (e.g., 24 for /24 or 255.255.255.0):${NC}"
    read -r SUBNET_MASK
    
    echo -e "${YELLOW}Enter gateway IP (default: $CURRENT_GATEWAY):${NC}"
    read -r GATEWAY_IP
    GATEWAY_IP=${GATEWAY_IP:-$CURRENT_GATEWAY}
    
    echo -e "${YELLOW}Enter DNS server (default: 1.1.1.1):${NC}"
    read -r DNS_SERVER
    DNS_SERVER=${DNS_SERVER:-1.1.1.1}
    
    # Configure dhcpcd.conf
    cat >> /etc/dhcpcd.conf << EOF

# Static IP configuration added by headless-setup
interface $CURRENT_INTERFACE
static ip_address=$STATIC_IP/$SUBNET_MASK
static routers=$GATEWAY_IP
static domain_name_servers=$DNS_SERVER
EOF

    echo -e "${GREEN}Static IP configuration added to /etc/dhcpcd.conf${NC}"
    echo -e "${YELLOW}You'll need to reboot for changes to take effect${NC}"
fi

# Configure SSH
echo
echo -e "${YELLOW}Would you like to harden SSH configuration? (y/n)${NC}"
read -r HARDEN_SSH

if [[ "$HARDEN_SSH" =~ ^[Yy]$ ]]; then
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Apply security settings
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    
    echo -e "${GREEN}SSH configuration hardened${NC}"
    echo -e "${YELLOW}Make sure you have set up SSH keys before disconnecting!${NC}"
    echo -e "${YELLOW}Restart SSH with: sudo systemctl restart ssh${NC}"
fi

# Set up automatic updates
echo
echo -e "${YELLOW}Would you like to enable automatic security updates? (y/n)${NC}"
read -r AUTO_UPDATES

if [[ "$AUTO_UPDATES" =~ ^[Yy]$ ]]; then
    apt update
    apt install -y unattended-upgrades
    
    # Configure unattended-upgrades
    cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

    echo -e "${GREEN}Automatic security updates enabled${NC}"
fi

echo
echo -e "${GREEN}Headless setup complete!${NC}"
echo -e "${YELLOW}You may need to reboot for all changes to take effect${NC}"
EOF

chmod +x ~/projects/raspberry-pi/bin/headless-setup

# Security hardening
log "Applying basic security hardening..."

# Ensure SSH is enabled
sudo systemctl enable ssh

# Create a .hushlogin file to suppress the login message
touch ~/.hushlogin

# Set up firewall if ufw is available
if command -v ufw &>/dev/null; then
    log "Setting up firewall..."
    sudo ufw allow ssh
    sudo ufw allow 1880/tcp comment 'Node-RED' 2>/dev/null || true
    sudo ufw allow 1883/tcp comment 'MQTT' 2>/dev/null || true
    
    # Only enable if not already enabled
    sudo ufw status | grep -q "Status: active" || sudo ufw --force enable
fi

# Final setup message
log "Raspberry Pi headless environment setup complete!"

if [ "$INSTALL_IOT" = true ]; then
    echo -e "${BLUE}Node-RED is available at: http://$(hostname -I | awk '{print $1}'):1880${NC}"
    echo -e "${BLUE}MQTT broker is running on: localhost:1883${NC}"
fi

if [ "$INSTALL_DEV" = true ]; then
    echo -e "${YELLOW}To activate the Python virtual environment: source ~/projects/raspberry-pi/venv/bin/activate${NC}"
    echo -e "${YELLOW}Remember to use 'uv pip' instead of 'pip' for package management${NC}"
fi

echo -e "${YELLOW}For headless setup assistance, run: sudo ~/projects/raspberry-pi/bin/headless-setup${NC}"
echo -e "${YELLOW}For system information, run: ~/projects/raspberry-pi/bin/pisystem${NC}"
