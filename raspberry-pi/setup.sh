#!/bin/bash
# Raspberry Pi specific setup script
# To be called from the main dotfiles setup.sh

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up Raspberry Pi environment...${NC}"

# Check if we're actually on a Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo &>/dev/null; then
    echo -e "${YELLOW}This doesn't appear to be a Raspberry Pi.${NC}"
    echo -e "${YELLOW}Skipping Raspberry Pi specific setup.${NC}"
    exit 0
fi

# Create directories
echo -e "${YELLOW}Creating Raspberry Pi project directories...${NC}"
mkdir -p ~/projects/raspberry-pi-project/{src,config,scripts,data,logs,web}

# Install Raspberry Pi specific packages
echo -e "${YELLOW}Installing Raspberry Pi specific packages...${NC}"
sudo apt update
sudo apt install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-rpi.gpio \
    python3-gpiozero \
    i2c-tools \
    wiringpi \
    mosquitto \
    mosquitto-clients \
    node-red

# Set up Python virtual environment
echo -e "${YELLOW}Setting up Python virtual environment...${NC}"
cd ~/projects/raspberry-pi-project
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo -e "${YELLOW}Installing Python packages...${NC}"
pip install --upgrade pip
pip install \
    flask \
    paho-mqtt \
    requests \
    gpiozero \
    RPi.GPIO \
    adafruit-blinka \
    python-dotenv

# Create Raspberry Pi specific configuration files
echo -e "${YELLOW}Creating Raspberry Pi configuration files...${NC}"

# Create .env file for project configuration
cat > ~/projects/raspberry-pi-project/.env << EOF
# Environment variables for Raspberry Pi project
PI_NAME=$(hostname)
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_TOPIC=home/$(hostname)
LOG_LEVEL=INFO
EOF

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
export PATH="\$HOME/projects/raspberry-pi-project/bin:\$PATH"

# Activate Python virtual environment if it exists
if [ -f "\$HOME/projects/raspberry-pi-project/venv/bin/activate" ]; then
    source "\$HOME/projects/raspberry-pi-project/venv/bin/activate"
fi
EOF

# Add Raspberry Pi specific configuration to .bashrc
if ! grep -q "source ~/dotfiles/raspberry-pi/bashrc" ~/.bashrc; then
    echo -e "\n# Source Raspberry Pi specific configuration" >> ~/.bashrc
    echo "source ~/dotfiles/raspberry-pi/bashrc" >> ~/.bashrc
fi

# Create a bin directory for scripts
mkdir -p ~/projects/raspberry-pi-project/bin

# Create a simple utility script
cat > ~/projects/raspberry-pi-project/bin/pisystem << 'EOF'
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

chmod +x ~/projects/raspberry-pi-project/bin/pisystem

# Configure services
echo -e "${YELLOW}Configuring services...${NC}"

# Enable and start MQTT broker
sudo systemctl enable mosquitto
sudo systemctl start mosquitto

# Enable and start Node-RED
sudo systemctl enable nodered.service
sudo systemctl start nodered.service

echo -e "${GREEN}Raspberry Pi environment setup complete!${NC}"
echo -e "${BLUE}Node-RED is available at: http://$(hostname -I | awk '{print $1}'):1880${NC}"
echo -e "${BLUE}MQTT broker is running on: $(hostname -I | awk '{print $1}'):1883${NC}"
echo -e "${YELLOW}To activate the Python virtual environment: source ~/projects/raspberry-pi-project/venv/bin/activate${NC}"
