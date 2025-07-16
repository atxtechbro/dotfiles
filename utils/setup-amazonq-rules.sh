#!/bin/bash
# Setup Amazon Q to use global knowledge base via symlink

set -e

# Define paths
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
SOURCE_RULES="$DOT_DEN/knowledge"
TARGET_RULES="$HOME/.amazonq/rules"
SOURCE_CONFIG="$DOT_DEN/.amazonq/global_context.json"
TARGET_CONFIG="$HOME/.aws/amazonq/global_context.json"

echo "Setting up Amazon Q global rules..."

# Check if source exists
if [ ! -d "$SOURCE_RULES" ]; then
    echo "❌ No knowledge directory found at $SOURCE_RULES"
    exit 1
fi

if [ ! -f "$SOURCE_CONFIG" ]; then
    echo "❌ No global context config found at $SOURCE_CONFIG"
    exit 1
fi

# Handle existing rules directory
if [ -e "$TARGET_RULES" ] && [ ! -L "$TARGET_RULES" ]; then
    # Backup existing rules
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$HOME/.amazonq/experimental-rules.backup.$TIMESTAMP"
    echo "Preserving existing experimental rules to $BACKUP_DIR"
    mv "$TARGET_RULES" "$BACKUP_DIR"
    echo "Experimental rules preserved. Consider making a PR to add useful rules to dotfiles repo"
fi

# Create parent directories
mkdir -p "$(dirname "$TARGET_RULES")"
mkdir -p "$(dirname "$TARGET_CONFIG")"

# Remove existing symlink if present
[ -L "$TARGET_RULES" ] && rm "$TARGET_RULES"

# Create symlink
ln -s "$SOURCE_RULES" "$TARGET_RULES"
echo "✅ Amazon Q global rules symlinked"

# Copy global context config
cp "$SOURCE_CONFIG" "$TARGET_CONFIG"
echo "✅ Global context configuration installed"

# Validate
if [ -L "$TARGET_RULES" ] && [ -f "$TARGET_CONFIG" ]; then
    echo "✅ Amazon Q global rules setup complete"
else
    echo "❌ Setup validation failed!"
    exit 1
fi