#!/bin/bash
# Script to install LSP servers for Neovim

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing LSP servers for Neovim...${NC}"

# Check for Neovim
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}Neovim is not installed. Please install Neovim first.${NC}"
    exit 1
fi

# Install Python dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"

# Use `--target` with uv to install Python tools (e.g., pyright, pynvim)
# This avoids system Python pollution and doesn't require a venv.
# Tools go in ~/.local/uv-tools — ensure it's in PATH.
if command -v uv &> /dev/null; then
    echo -e "${BLUE}Using uv for Python package management...${NC}"
    UV_TOOLS_PATH="$HOME/.local/uv-tools"
    uv pip install --target "$UV_TOOLS_PATH" pynvim pyright
    
    # Add to PATH if not already there
    if ! grep -q "$UV_TOOLS_PATH/bin" ~/.bashrc; then
        echo -e "${BLUE}Adding $UV_TOOLS_PATH/bin to PATH in ~/.bashrc...${NC}"
        echo "export PATH=\"\$PATH:$UV_TOOLS_PATH/bin\"" >> ~/.bashrc
    fi
else
    echo -e "${BLUE}Using pip for Python package management...${NC}"
    pip install --user pynvim pyright
fi

# Install Node.js dependencies if Node.js is available
if command -v npm &> /dev/null; then
    echo -e "${YELLOW}Installing Node.js dependencies...${NC}"
    npm install -g neovim bash-language-server vscode-langservers-extracted typescript typescript-language-server pyright
else
    echo -e "${YELLOW}Node.js not found. Skipping Node.js dependencies.${NC}"
    echo -e "${BLUE}To install Node.js LSP servers, install Node.js and run:${NC}"
    echo -e "npm install -g neovim bash-language-server vscode-langservers-extracted typescript typescript-language-server pyright"
fi

# Install Lua LSP if available
if command -v luarocks &> /dev/null; then
    echo -e "${YELLOW}Installing Lua LSP...${NC}"
    luarocks install --local luacheck
else
    echo -e "${YELLOW}LuaRocks not found. Skipping Lua LSP installation.${NC}"
    echo -e "${BLUE}To install Lua LSP, install LuaRocks and run:${NC}"
    echo -e "luarocks install --local luacheck"
fi
    
# Check for xmllint (XML formatting tool)
echo -e "${YELLOW}Checking for xmllint (XML formatting)...${NC}"
if ! command -v xmllint &> /dev/null; then
    echo -e "${RED}xmllint not found. Install libxml2-utils (Debian/Ubuntu) or libxml2 (macOS) to enable XML formatting.${NC}"
fi

# Check for xmllint (XML formatting tool)
echo -e "${YELLOW}Checking for xmllint (XML formatting)...${NC}"
if ! command -v xmllint &> /dev/null; then
    echo -e "${RED}xmllint not found. Install libxml2-utils (Debian/Ubuntu) or libxml2 (macOS) to enable XML formatting.${NC}"
fi

# Check for xmllint (XML formatting tool)
echo -e "${YELLOW}Checking for xmllint (XML formatting)...${NC}"
if ! command -v xmllint &> /dev/null; then
    echo -e "${RED}xmllint not found. Install libxml2-utils (Debian/Ubuntu) or libxml2 (macOS) to enable XML formatting.${NC}"
fi

# Run Neovim with PackerSync to install plugins
echo -e "${YELLOW}Installing Neovim plugins...${NC}"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Let Mason handle LSP server installation through ensure_installed in init.lua
echo -e "${YELLOW}Starting Neovim to allow Mason to install LSP servers...${NC}"
echo -e "${BLUE}(This uses automatic_installation and ensure_installed in init.lua)${NC}"
nvim --headless -c "lua require('mason')" -c "quitall"

echo -e "${GREEN}LSP servers installation complete!${NC}"
echo -e "${BLUE}You may need to restart Neovim for all changes to take effect.${NC}"

