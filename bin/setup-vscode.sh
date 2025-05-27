#!/bin/bash
# setup-vscode.sh: Deploy VS Code/Cursor config files from dotfiles to user config dirs
# Usage: Run from dotfiles/bin. Expects canonical files in ../vscode/

set +e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
DIVIDER="----------------------------------------"

# Source and target editors
EDITORS=("Code" "Cursor")

# Canonical source directory (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../vscode"

SRC_SETTINGS="$SRC_DIR/settings.json"
SRC_KEYBINDINGS="$SRC_DIR/keybindings.json"

# Check for source files
if [[ ! -f "$SRC_SETTINGS" || ! -f "$SRC_KEYBINDINGS" ]]; then
  echo -e "${RED}Error: settings.json or keybindings.json not found in $SRC_DIR${NC}"
  exit 1
fi

# OS detection
OS_TYPE="Unknown"
IS_WSL=false
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS_TYPE="Linux"
  if grep -q Microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macOS"
else
  echo -e "${YELLOW}Warning: Unrecognized OS: $OSTYPE. Attempting best guess...${NC}"
fi

# Deploy function
deploy_config() {
  local editor="$1"
  local target_dir
  target_dir="$(get_target_dir "$editor")"
  if [[ -z "$target_dir" ]]; then
    echo -e "${YELLOW}Skipping $editor: could not determine target directory for this OS.${NC}"
    return
  fi
  mkdir -p "$target_dir"
  for file in settings.json keybindings.json; do
    local src_file="$SRC_DIR/$file"
    local tgt_file="$target_dir/$file"
    if [[ -e "$tgt_file" ]]; then
      mv "$tgt_file" "$tgt_file.bak.$(date +%s)"
      echo -e "${YELLOW}Backed up existing $tgt_file to $tgt_file.bak${NC}"
    fi
    ln -s "$src_file" "$tgt_file" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}Symlinked $file for $editor -> $tgt_file${NC}"
    else
      cp "$src_file" "$tgt_file"
      echo -e "${BLUE}Copied $file for $editor -> $tgt_file (symlink failed)${NC}"
    fi
  done
}

echo -e "${DIVIDER}"
echo -e "${GREEN}Setting up VS Code and Cursor config files...${NC}"
echo -e "${DIVIDER}"

for editor in "${EDITORS[@]}"; do
  deploy_config "$editor"
done

echo -e "${DIVIDER}"
echo -e "${GREEN}VS Code/Cursor config setup complete!${NC}"
echo -e "${DIVIDER}"

# Simple VS Code/Cursor config setup for dotfiles
# Source this from setup.sh

setup_vscode_configs() {
  local editors=("Code" "Cursor")
  local src_dir="$DOT_DEN/vscode"
  local files=("settings.json" "keybindings.json")

  for editor in "${editors[@]}"; do
    local target_dir=""
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      target_dir="$HOME/.config/$editor/User"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      target_dir="$HOME/Library/Application Support/$editor/User"
    elif grep -q Microsoft /proc/version 2>/dev/null; then
      local win_home="/mnt/c/Users/$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')"
      target_dir="$win_home/AppData/Roaming/$editor/User"
    else
      continue
    fi
    mkdir -p "$target_dir"
    for file in "${files[@]}"; do
      local src_file="$src_dir/$file"
      local tgt_file="$target_dir/$file"
      if [[ -f "$src_file" ]]; then
        mv "$tgt_file" "$tgt_file.bak.$(date +%s)" 2>/dev/null
        ln -sf "$src_file" "$tgt_file" 2>/dev/null || cp "$src_file" "$tgt_file"
      fi
    done
  done
} 