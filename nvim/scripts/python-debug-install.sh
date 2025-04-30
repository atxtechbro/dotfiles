#!/bin/bash
# Script to install Python debugging tools for Neovim

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

if ! grep -q "$HOME/.local/uv-tools/bin" ~/.bashrc; then
    echo -e "${BLUE}Adding ~/.local/uv-tools/bin to PATH in ~/.bashrc...${NC}"
    echo 'export PATH="$HOME/.local/uv-tools/bin:$PATH"' >> ~/.bashrc
fi

# Install minimal DAP plugin for Neovim
echo -e "${YELLOW}Installing minimal DAP plugin with Packer...${NC}"
# Make nvim install the nvim-dap plugin, run PackerCompile, and ensure config.dap is loaded
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' -c 'PackerCompile' -c 'lua pcall(require, "config.dap")'

echo -e "${GREEN}Python debugging tools installation complete!${NC}"
echo -e "${YELLOW}Usage:${NC}"
echo -e "1. Open a Python file in Neovim"
echo -e "2. Press F9 to set breakpoints"
echo -e "3. Press F5 to start debugging"
echo -e "4. Alternative for setting breakpoints:"
echo -e "   - Keybinding: <leader>bp (usually space+bp)"
