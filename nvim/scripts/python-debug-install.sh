#!/bin/bash
# Script to install Python debugging tools for Neovim

set -e  # Exit on error

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing Python debugging tools for Neovim...${NC}"

# Check for Neovim
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}Neovim is not installed. Please install Neovim first.${NC}"
    exit 1
fi

# Install debugpy for Python debugging
echo -e "${YELLOW}Installing Python debugpy...${NC}"

# Use `--target` with uv to install Python tools (e.g., debugpy)
# This avoids system Python pollution and doesn't require a venv.
# Tools go in ~/.local/uv-tools — ensure it's in PATH.
echo -e "${BLUE}Using uv for Python package management...${NC}"
UV_TOOLS_PATH="$HOME/.local/uv-tools"
uv pip install --target "$UV_TOOLS_PATH" debugpy

# Verify debugpy is correctly installed
if [ -d "$UV_TOOLS_PATH/debugpy" ]; then
    echo -e "${GREEN}✓ Debugpy installed successfully at $UV_TOOLS_PATH/debugpy${NC}"
    
    # Check specifically for the adapter directory
    if [ -d "$UV_TOOLS_PATH/debugpy/adapter" ]; then
        echo -e "${BLUE}Neovim will use the debugpy adapter at: $UV_TOOLS_PATH/debugpy/adapter${NC}"
    else
        echo -e "${YELLOW}Warning: Debugpy adapter directory not found at $UV_TOOLS_PATH/debugpy/adapter${NC}"
        echo -e "${YELLOW}You may need to update the path in nvim/lua/config/dap.lua${NC}"
    fi
else
    echo -e "${RED}× Debugpy installation failed. Directory not found at $UV_TOOLS_PATH/debugpy${NC}"
    exit 1
fi

if ! grep -q "export PATH=\"\$HOME/.local/uv-tools/bin:\$PATH\"" ~/.bashrc; then
    echo -e "${BLUE}Adding ~/.local/uv-tools/bin to PATH in ~/.bashrc...${NC}"
    echo "export PATH=\"\$HOME/.local/uv-tools/bin:\$PATH\"" >> ~/.bashrc
fi

# Install minimal DAP plugin for Neovim
echo -e "${YELLOW}Installing minimal DAP plugin with Packer...${NC}"
# Make nvim install the nvim-dap plugin, run PackerCompile, and ensure config.dap is loaded
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' -c 'PackerCompile' -c 'lua pcall(require, "config.dap")'

echo -e "${GREEN}✓ Python debugger installed successfully${NC}"
