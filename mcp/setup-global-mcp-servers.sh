#!/bin/bash

# =========================================================
# GLOBAL MCP SERVER SETUP SCRIPT
# =========================================================
# PURPOSE: Sets up MCP servers in a global location for
# system-wide access, implementing the global-first principle
# =========================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Global MCP directory
GLOBAL_MCP_DIR="$HOME/.mcp"
GLOBAL_SERVERS_DIR="$GLOBAL_MCP_DIR/servers"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SERVERS_DIR="$SCRIPT_DIR/servers"

echo "Setting up global MCP servers..."

# Create global directories
echo "Creating global MCP directories..."
mkdir -p "$GLOBAL_SERVERS_DIR"

# Function to install a server globally
install_server_globally() {
    local server_name="$1"
    local setup_script="$2"
    
    echo -e "\n${GREEN}Setting up global $server_name...${NC}"
    
    # Check if server already exists globally
    if [[ -d "$GLOBAL_SERVERS_DIR/$server_name" ]]; then
        echo -e "${YELLOW}$server_name already exists globally. Updating...${NC}"
    fi
    
    # Create server directory
    mkdir -p "$GLOBAL_SERVERS_DIR/$server_name"
    
    # Copy server files to global location
    if [[ -d "$LOCAL_SERVERS_DIR/$server_name" ]]; then
        cp -r "$LOCAL_SERVERS_DIR/$server_name/"* "$GLOBAL_SERVERS_DIR/$server_name/" 2>/dev/null || true
    fi
    
    # Run the server-specific setup if it exists
    if [[ -f "$SCRIPT_DIR/$setup_script" ]]; then
        # Temporarily change SERVER_DIR environment variable for the setup script
        (
            export MCP_GLOBAL_INSTALL="true"
            export SERVER_DIR="$GLOBAL_SERVERS_DIR/$server_name"
            cd "$GLOBAL_SERVERS_DIR/$server_name"
            bash "$SCRIPT_DIR/$setup_script"
        )
    fi
}

# Install each MCP server globally
install_server_globally "git-mcp-server" "setup-git-mcp.sh"
install_server_globally "github" "setup-github-mcp.sh"
install_server_globally "filesystem-mcp-server" "setup-filesystem-mcp.sh"
install_server_globally "gitlab-mcp-server" "setup-gitlab-mcp.sh"

# Create a global wrapper directory
GLOBAL_WRAPPER_DIR="$GLOBAL_MCP_DIR/wrappers"
mkdir -p "$GLOBAL_WRAPPER_DIR"

# Copy wrapper scripts to global location and update them
echo -e "\n${GREEN}Setting up global wrapper scripts...${NC}"
for wrapper in "$SCRIPT_DIR"/*-wrapper.sh; do
    if [[ -f "$wrapper" ]]; then
        wrapper_name=$(basename "$wrapper")
        cp "$wrapper" "$GLOBAL_WRAPPER_DIR/$wrapper_name"
        # Make it executable
        chmod +x "$GLOBAL_WRAPPER_DIR/$wrapper_name"
    fi
done

# Create a global mcp.json from template
echo -e "\n${GREEN}Creating global MCP configuration...${NC}"
CONFIG_TEMPLATE="$SCRIPT_DIR/config/global-mcp-template.json"

if [[ -f "$CONFIG_TEMPLATE" ]]; then
    cp "$CONFIG_TEMPLATE" "$GLOBAL_MCP_DIR/mcp.json"
    echo "Global MCP configuration created from template"
else
    echo -e "${RED}Error: Configuration template not found at $CONFIG_TEMPLATE${NC}"
    exit 1
fi

# Add global MCP wrappers to PATH
echo -e "\n${GREEN}Adding global MCP to PATH...${NC}"
if ! grep -q "export PATH=\"\$HOME/.mcp/wrappers:\$PATH\"" ~/.bashrc; then
    echo "export PATH=\"\$HOME/.mcp/wrappers:\$PATH\"" >> ~/.bashrc
    echo "Added ~/.mcp/wrappers to PATH in ~/.bashrc"
fi

echo -e "\n${GREEN}✓ Global MCP server setup complete!${NC}"
echo "MCP servers are now installed globally in: $GLOBAL_MCP_DIR"
echo "To use global MCP configuration, set:"
echo "  export CLAUDE_MCP_CONFIG=\"$GLOBAL_MCP_DIR/mcp.json\""
echo ""
echo "Or use the claude alias which already includes global MCP configuration."