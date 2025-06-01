#!/bin/bash
# setup-claude-desktop-mcp.sh - Install and configure Claude Desktop with Clojure MCP integration
# This script follows the "spilled coffee principle" - ensuring reproducible setup

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"
CLOJURE_MCP_DIR="$DOTFILES_DIR/mcp/clojure-mcp"
CONFIG_DIR="$HOME/.config/Claude"

echo -e "${GREEN}Setting up Claude Desktop with Clojure MCP integration...${NC}"

# Check for required dependencies and install if possible
check_dependency() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${YELLOW}$1 is not installed. Attempting to install...${NC}"
    
    case "$1" in
      "nodejs"|"npm")
        echo -e "${YELLOW}Installing Node.js and npm...${NC}"
        if command -v apt-get &> /dev/null; then
          sudo apt-get update
          sudo apt-get install -y nodejs npm
        elif command -v pacman &> /dev/null; then
          sudo pacman -Sy --noconfirm nodejs npm
        else
          echo -e "${RED}Error: Unsupported package manager. Please install Node.js and npm manually.${NC}"
          exit 1
        fi
        ;;
      "icoutils")
        echo -e "${YELLOW}Installing icoutils...${NC}"
        if command -v apt-get &> /dev/null; then
          sudo apt-get update
          sudo apt-get install -y icoutils
        elif command -v pacman &> /dev/null; then
          sudo pacman -Sy --noconfirm icoutils
        else
          echo -e "${RED}Error: Unsupported package manager. Please install icoutils manually.${NC}"
          exit 1
        fi
        ;;
      *)
        echo -e "${RED}Error: $1 is required but not installed.${NC}"
        echo -e "Please install $1 first."
        exit 1
        ;;
    esac
  fi
}

# Check for required dependencies
check_dependency "git"
check_dependency "nodejs"
check_dependency "npm"
check_dependency "icoutils"

# Create configuration directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Install Claude Desktop for Debian
echo -e "${YELLOW}Installing Claude Desktop for Debian...${NC}"
CLAUDE_DESKTOP_DIR="$DOTFILES_DIR/mcp/claude-desktop-debian"

# Clone or update the Claude Desktop Debian repository
if [ -d "$CLAUDE_DESKTOP_DIR" ]; then
  echo -e "${YELLOW}Updating existing Claude Desktop Debian repository...${NC}"
  cd "$CLAUDE_DESKTOP_DIR"
  git pull
else
  echo -e "${YELLOW}Cloning Claude Desktop Debian repository...${NC}"
  mkdir -p "$(dirname "$CLAUDE_DESKTOP_DIR")"
  git clone https://github.com/aaddrick/claude-desktop-debian.git "$CLAUDE_DESKTOP_DIR"
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

# Configure Claude Desktop to use Clojure MCP
echo -e "${YELLOW}Configuring Claude Desktop to use Clojure MCP...${NC}"

# Create MCP configuration for Claude Desktop
cat > "$CONFIG_DIR/mcp.json" << EOF
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