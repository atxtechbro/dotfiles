#!/bin/bash
# Fix npm prefix configuration conflict with nvm

# Check if .npmrc exists and has prefix setting
if [ -f "$HOME/.npmrc" ] && grep -q "prefix=" "$HOME/.npmrc"; then
  # Create backup and remove prefix line in one operation
  sed '/prefix=/d' "$HOME/.npmrc" > "$HOME/.npmrc.new"
  mv "$HOME/.npmrc" "$HOME/.npmrc.bak"
  mv "$HOME/.npmrc.new" "$HOME/.npmrc"
fi
