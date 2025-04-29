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
if command -v uv &> /dev/null; then
    echo -e "${BLUE}Using uv for Python package management...${NC}"
    uv pip install --user debugpy
else
    echo -e "${BLUE}Using pip for Python package management...${NC}"
    pip install --user debugpy
fi

# Install DAP plugins for Neovim
echo -e "${YELLOW}Installing DAP plugins with Packer...${NC}"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

echo -e "${GREEN}Python debugging tools installation complete!${NC}"
echo -e "${YELLOW}Usage:${NC}"
echo -e "1. Open a Python file in Neovim"
echo -e "2. Set breakpoints with <leader>b"
echo -e "3. Press F5 to start debugging"