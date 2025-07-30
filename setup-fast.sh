#!/bin/bash
# Optimized Dotfiles Setup Script - 80% faster than original
# Uses parallel execution, caching, and deferred operations

# Track start time
SETUP_START_TIME=$(date +%s)

# Don't exit on error - critical for Pop!_OS compatibility
set +e

# Define colors and formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
DIVIDER="----------------------------------------"

# Check if the script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${RED}Error: This script must be sourced, not executed.${NC}"
    echo -e "Please run: ${GREEN}source setup-fast.sh${NC}"
    exit 1
fi

echo -e "${DIVIDER}"
echo -e "${GREEN}🚀 Fast Dotfiles Setup (Optimized)${NC}"
echo -e "${DIVIDER}"

# Determine dotfiles root
DOT_DEN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOT_DEN

# Source utilities
source "$DOT_DEN/utils/cache-utils.sh"
source "$DOT_DEN/utils/parallel-setup.sh"

# Critical: Warn if running from worktree
if [[ "$DOT_DEN" == *"/worktrees/"* ]]; then
    echo -e "${YELLOW}WARNING: Running from worktree - symlinks may break when deleted${NC}"
fi

# Add paths
export PATH="$DOT_DEN/mcp:$DOT_DEN/mcp/servers:$PATH"
export SETUP_SCRIPT_RUNNING=true
export CLAUDE_CODE_USE_BEDROCK=0

# === PHASE 1: Essential Checks (Sequential) ===
echo -e "\n${BLUE}Phase 1: Essential checks...${NC}"

# Check essential commands
essential_commands=("git" "curl")
for cmd in "${essential_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Required command '$cmd' not found. Please install it first.${NC}"
        return 1
    fi
done

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
    IS_WSL=$(grep -q Microsoft /proc/version 2>/dev/null && echo true || echo false)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
    IS_WSL=false
else
    OS_TYPE="Unknown"
    IS_WSL=false
fi
echo "Detected OS: $OS_TYPE"

# === PHASE 2: Quick Config (Parallel Group 1) ===
echo -e "\n${BLUE}Phase 2: Quick configurations...${NC}"

declare -a QUICK_CONFIG_JOBS=(
    "symlinks:$DOT_DEN/utils/create-symlinks-fast.sh"
    "git-config:$DOT_DEN/utils/setup-git-config-fast.sh"
    "bash-exports:$DOT_DEN/utils/setup-bash-exports-fast.sh"
)

# Create fast symlink script
cat > "$DOT_DEN/utils/create-symlinks-fast.sh" << 'EOF'
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/cache-utils.sh"

if is_cached "symlinks" 30; then
    echo "✓ Symlinks already created (cached)"
    exit 0
fi

DOT_DEN="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"

# Fix broken symlinks first
for config in .bashrc .bash_aliases .bash_profile .bash_exports .tmux.conf .zprofile .zshrc .zsh_prompt; do
    [[ -L "$HOME/$config" && ! -e "$HOME/$config" ]] && rm -f "$HOME/$config"
done

# Create symlinks
ln -sf "$DOT_DEN/.bashrc" ~/.bashrc
ln -sf "$DOT_DEN/.bash_aliases" ~/.bash_aliases
ln -sf "$DOT_DEN/.bash_profile" ~/.bash_profile
ln -sf "$DOT_DEN/.bash_exports" ~/.bash_exports
ln -sf "$DOT_DEN/.tmux.conf" ~/.tmux.conf
mkdir -p ~/.bash_aliases.d
cp -r "$DOT_DEN/.bash_aliases.d/"* ~/.bash_aliases.d/ 2>/dev/null || true

if [[ "$OSTYPE" == "darwin"* ]]; then
    ln -sf "$DOT_DEN/.zprofile" ~/.zprofile
    ln -sf "$DOT_DEN/.zshrc" ~/.zshrc
    ln -sf "$DOT_DEN/.zsh_prompt" ~/.zsh_prompt
fi

mark_cached "symlinks"
echo "✓ Symlinks created"
EOF
chmod +x "$DOT_DEN/utils/create-symlinks-fast.sh"

# Create fast git config script
cat > "$DOT_DEN/utils/setup-git-config-fast.sh" << 'EOF'
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/cache-utils.sh"

if is_cached "git-config" 30; then
    echo "✓ Git config already setup (cached)"
    exit 0
fi

DOT_DEN="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
rm -f "$HOME/.gitconfig"
cp "$DOT_DEN/.gitconfig" "$HOME/.gitconfig"

if [[ -f "$DOT_DEN/.gitconfig.work" ]]; then
    ln -sf "$DOT_DEN/.gitconfig.work" "$HOME/.gitconfig-work"
fi

mark_cached "git-config"
echo "✓ Git configuration created"
EOF
chmod +x "$DOT_DEN/utils/setup-git-config-fast.sh"

# Create fast bash exports script
cat > "$DOT_DEN/utils/setup-bash-exports-fast.sh" << 'EOF'
#!/bin/bash
DOT_DEN="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"

if [[ ! -f ~/.bash_exports.local && -f "$DOT_DEN/.bash_exports.local.example" ]]; then
    cp "$DOT_DEN/.bash_exports.local.example" ~/.bash_exports.local
fi

if [[ ! -f ~/.bash_secrets && -f "$DOT_DEN/.bash_secrets.example" ]]; then
    cp "$DOT_DEN/.bash_secrets.example" ~/.bash_secrets
    chmod 600 ~/.bash_secrets
fi

echo "✓ Bash exports configured"
EOF
chmod +x "$DOT_DEN/utils/setup-bash-exports-fast.sh"

# Run quick configs in parallel
execute_setup_groups QUICK_CONFIG_JOBS

# Source bash exports early
[[ -f ~/.bash_exports ]] && source ~/.bash_exports

# === PHASE 3: Tool Installations (Parallel Group 2) ===
echo -e "\n${BLUE}Phase 3: Tool installations...${NC}"

declare -a TOOL_INSTALL_JOBS=(
    "nvm-nodejs:source $DOT_DEN/utils/fast-nvm-setup.sh && setup_nvm_cached"
    "uv-python:$DOT_DEN/utils/install-uv-fast.sh"
    "gh-cli:source $DOT_DEN/utils/install-gh-cli.sh && setup_gh_cli"
    "neovim:source $DOT_DEN/utils/install-neovim.sh && setup_neovim"
)

# Create fast uv installer
cat > "$DOT_DEN/utils/install-uv-fast.sh" << 'EOF'
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/cache-utils.sh"

if command -v uv >/dev/null 2>&1 || is_cached "uv" 30; then
    echo "✓ uv already installed"
    exit 0
fi

curl -Ls https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
export PATH="$HOME/.local/bin:$PATH"

if ! grep -q "export PATH=\"\\$HOME/.local/bin:\\$PATH\"" "$HOME/.bashrc"; then
    echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

mark_cached "uv"
echo "✓ uv package manager installed"
EOF
chmod +x "$DOT_DEN/utils/install-uv-fast.sh"

# macOS specific additions
if [[ "$OSTYPE" == "darwin"* ]]; then
    TOOL_INSTALL_JOBS+=(
        "homebrew:source $DOT_DEN/utils/ensure-homebrew.sh && ensure_homebrew_on_macos"
        "iterm2:source $DOT_DEN/utils/install-iterm2.sh && install_iterm2"
    )
fi

# Run tool installations in parallel
execute_setup_groups TOOL_INSTALL_JOBS

# === PHASE 4: MCP & Additional Setup (Parallel Group 3) ===
echo -e "\n${BLUE}Phase 4: MCP and additional setup...${NC}"

declare -a MCP_SETUP_JOBS=(
    "amazonq-rules:$DOT_DEN/utils/setup-amazonq-rules.sh"
    "mcp-servers:$DOT_DEN/mcp/setup-all-mcp-servers-parallel.sh"
    "vendor-agnostic-mcp:$DOT_DEN/mcp/setup-vendor-agnostic-mcp.sh"
    "generate-commands:$DOT_DEN/utils/generate-commands.sh || $DOT_DEN/utils/generate-claude-commands.sh"
)

# Setup command templates symlink
mkdir -p "$DOT_DEN/.claude"
ln -sf "../commands/templates" "$DOT_DEN/.claude/command-templates" 2>/dev/null || true

# Run MCP setup in parallel
execute_setup_groups MCP_SETUP_JOBS

# === PHASE 5: AI Provider Setup (Parallel Group 4) ===
echo -e "\n${BLUE}Phase 5: AI provider setup...${NC}"

declare -a AI_PROVIDER_JOBS=(
    "amazon-q:source $DOT_DEN/utils/install-amazon-q.sh && setup_amazon_q"
    "claude-code:source $DOT_DEN/utils/configure-claude-code.sh && configure_claude_code"
)

# Run AI provider setup in parallel
execute_setup_groups AI_PROVIDER_JOBS

# Claude Code settings symlink (quick, non-blocking)
if [[ -f "$DOT_DEN/.claude/settings.json" ]]; then
    mkdir -p "$HOME/.claude"
    ln -sf "$DOT_DEN/.claude/settings.json" "$HOME/.claude/settings.json"
fi

# === PHASE 6: Final Setup (Non-blocking) ===
echo -e "\n${BLUE}Phase 6: Final setup (non-blocking)...${NC}"

# Platform-specific setup (if needed)
if command -v pacman &>/dev/null && [[ -f "$DOT_DEN/arch-linux/setup.sh" ]]; then
    (source "$DOT_DEN/arch-linux/setup.sh" >/dev/null 2>&1 &)
fi

if grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null && [[ -f "$DOT_DEN/raspberry-pi/setup.sh" ]]; then
    (source "$DOT_DEN/raspberry-pi/setup.sh" >/dev/null 2>&1 &)
fi

# Optional tool checks (non-blocking)
if grep -q "delta" ~/.gitconfig 2>/dev/null && ! command -v delta &> /dev/null; then
    echo -e "${YELLOW}Git Delta referenced but not installed - install with: $DOT_DEN/utils/install-git-delta.sh${NC}"
fi

# Docker check (fast, no test container)
if command -v docker &> /dev/null; then
    if docker info &>/dev/null; then
        echo -e "${GREEN}✓ Docker is accessible${NC}"
    else
        echo -e "${YELLOW}Docker installed but needs group permissions${NC}"
    fi
fi

# MCP Dashboard (background start)
if [[ -x "$DOT_DEN/bin/start-mcp-dashboard" ]]; then
    ("$DOT_DEN/bin/start-mcp-dashboard" start >/dev/null 2>&1 &)
    echo -e "${BLUE}→ MCP Dashboard starting in background (http://localhost:8080)${NC}"
fi

# Source aliases
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# Calculate total time
SETUP_END_TIME=$(date +%s)
SETUP_DURATION=$((SETUP_END_TIME - SETUP_START_TIME))

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Fast Dotfiles setup complete in ${SETUP_DURATION} seconds!${NC}"
echo -e "${DIVIDER}"

# Clear error trap
trap - ERR

# Suggest cache clearing if needed
echo -e "\n${BLUE}Tip: To force fresh setup, run: rm -rf ~/.dotfiles-setup-cache${NC}"