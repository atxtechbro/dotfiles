#!/bin/bash
# Setup script for Claude Desktop with MCP integration
# This script follows the "Spilled Coffee Principle" - ensuring reproducible setup
# and the "Versioning Mindset" - building on previous work rather than reinventing
#
# NOTE: For Windows and macOS users, download the official Claude Desktop app from:
# https://claude.ai/download
#
# We're using our own fork of the Claude Desktop Debian repository:
# https://github.com/atxtechbro/claude-desktop-debian

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"
CLAUDE_DESKTOP_DIR="$DOTFILES_DIR/mcp/claude-desktop-debian"
CONFIG_DIR=""
MCP_CONFIG_FILE=""

# Detect operating system
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected"
    OS_TYPE="macos"
    CONFIG_DIR="$HOME/Library/Application Support/Claude"
    MCP_CONFIG_FILE="$CONFIG_DIR/mcp.json"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo "Windows detected"
    OS_TYPE="windows"
    CONFIG_DIR="$APPDATA/Claude"
    MCP_CONFIG_FILE="$CONFIG_DIR/mcp.json"
  else
    echo "Linux detected"
    OS_TYPE="linux"
    CONFIG_DIR="$HOME/.config/Claude"
    MCP_CONFIG_FILE="$CONFIG_DIR/mcp.json"
  fi
}

# Check for required dependencies on Linux
check_linux_dependencies() {
  for dep in "$@"; do
    if ! command -v $dep &> /dev/null; then
      echo -e "${YELLOW}$dep is not installed. Attempting to install...${NC}"
      
      if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y $dep
      elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm $dep
      else
        echo -e "${RED}Error: Unsupported package manager. Please install $dep manually.${NC}"
        exit 1
      fi
    fi
  done
}

# Install Claude Desktop on Linux
install_linux_claude_desktop() {
  echo -e "${YELLOW}Installing Claude Desktop for Linux...${NC}"
  
  # Clone or update our fork of the Claude Desktop Debian repository
  if [ -d "$CLAUDE_DESKTOP_DIR" ]; then
    echo -e "${YELLOW}Updating existing Claude Desktop Debian repository...${NC}"
    cd "$CLAUDE_DESKTOP_DIR"
    git pull
  else
    echo -e "${YELLOW}Cloning Claude Desktop Debian repository from our fork...${NC}"
    mkdir -p "$(dirname "$CLAUDE_DESKTOP_DIR")"
    git clone https://github.com/atxtechbro/claude-desktop-debian.git "$CLAUDE_DESKTOP_DIR" || {
      echo -e "${RED}Error: Failed to clone repository.${NC}"
      exit 1
    }
    cd "$CLAUDE_DESKTOP_DIR"
  fi

  # Build the package
  echo -e "${YELLOW}Building Claude Desktop package...${NC}"
  ./build.sh

  # Install the package
  echo -e "${YELLOW}Installing Claude Desktop package...${NC}"
  DEB_FILE=$(find . -name "claude-desktop_*_amd64.deb" | sort -V | tail -n 1)
  if [ -n "$DEB_FILE" ]; then
    sudo apt install -y "$DEB_FILE"
    echo -e "${GREEN}✓ Claude Desktop installed successfully${NC}"
  else
    echo -e "${RED}Error: Could not find Claude Desktop .deb package${NC}"
    exit 1
  fi
  
  # Create a launcher script to ensure Claude Desktop uses our MCP configuration
  LAUNCHER_PATH="$HOME/.local/bin/claude-desktop-mcp"
  mkdir -p "$(dirname "$LAUNCHER_PATH")"

  cat > "$LAUNCHER_PATH" << EOF
#!/bin/bash
# Launcher script for Claude Desktop with Clojure MCP integration

# Start Clojure MCP server if not already running
if ! pgrep -f "clojure.*mcp.*server" > /dev/null; then
  echo "Starting Clojure MCP server..."
  nohup $DOTFILES_DIR/mcp/clojure-mcp-wrapper.sh start > /tmp/clojure-mcp.log 2>&1 &
  sleep 2
fi

# Launch Claude Desktop
claude-desktop
EOF

  chmod +x "$LAUNCHER_PATH"

  # Create desktop entry for Claude Desktop with MCP
  DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/claude-desktop-mcp.desktop"
  mkdir -p "$(dirname "$DESKTOP_ENTRY_PATH")"

  cat > "$DESKTOP_ENTRY_PATH" << EOF
[Desktop Entry]
Name=Claude Desktop (MCP)
Comment=Claude Desktop with Clojure MCP integration
Exec=$LAUNCHER_PATH
Icon=claude-desktop
Terminal=false
Type=Application
Categories=Development;
EOF
}

# Configure MCP integration
configure_mcp() {
  echo -e "${YELLOW}Configuring Claude Desktop to use Clojure MCP...${NC}"
  
  # Create configuration directory if it doesn't exist
  mkdir -p "$CONFIG_DIR"
  
  # Create MCP configuration specifically for Clojure MCP server
  cat > "$MCP_CONFIG_FILE" << EOF
{
  "servers": [
    {
      "name": "clojure-mcp",
      "url": "http://localhost:7777",
      "enabled": true
    }
  ]
}
EOF

  echo -e "${GREEN}✓ MCP configuration created at $MCP_CONFIG_FILE${NC}"
}

# Main execution
echo -e "${GREEN}Setting up Claude Desktop with Clojure MCP integration...${NC}"

# Detect operating system
detect_os

# OS-specific setup
case "$OS_TYPE" in
  "linux")
    echo -e "${YELLOW}Setting up Claude Desktop for Linux...${NC}"
    check_linux_dependencies git nodejs npm icoutils
    install_linux_claude_desktop
    configure_mcp
    
    echo -e "${GREEN}Claude Desktop with Clojure MCP integration setup complete!${NC}"
    echo -e "To start using Claude Desktop with Clojure MCP:"
    echo -e "1. Launch 'Claude Desktop (MCP)' from your application menu"
    echo -e "2. Or run: ${YELLOW}claude-desktop-mcp${NC}"
    echo -e "\nNote: After first launch, you may need to quit and restart the application from the system tray for it to work properly."
    echo -e "When you launch Claude Desktop:"
    echo -e "1. You'll see a 'Claude for Windows' screen with a black 'Get Started' button"
    echo -e "   (Note: Yes, it says 'Windows' even though you're on Linux)"
    echo -e "2. Click 'Get Started' to proceed to the email sign-in screen"
    echo -e "3. Sign in with the email associated with your Claude account"
    ;;
    
  "macos")
    echo -e "${YELLOW}Setting up Claude Desktop for macOS...${NC}"
    echo -e "Please download and install Claude Desktop from: https://claude.ai/download"
    configure_mcp
    echo -e "${GREEN}MCP configuration complete!${NC}"
    echo -e "After installing Claude Desktop, it will use the Clojure MCP server automatically."
    ;;
    
  "windows")
    echo -e "${YELLOW}Setting up Claude Desktop for Windows...${NC}"
    echo -e "Please download and install Claude Desktop from: https://claude.ai/download"
    configure_mcp
    echo -e "${GREEN}MCP configuration complete!${NC}"
    echo -e "After installing Claude Desktop, it will use the Clojure MCP server automatically."
    ;;
    
  *)
    echo -e "${RED}Unsupported operating system: $OS_TYPE${NC}"
    exit 1
    ;;
esac