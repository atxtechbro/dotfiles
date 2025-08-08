#!/bin/bash
# Setup Amazon Q to use global knowledge base via symlink

set -e

# Define paths
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
SOURCE_KNOWLEDGE="$DOT_DEN/knowledge"
TARGET_KNOWLEDGE="$HOME/.amazonq/rules"
SOURCE_CONFIG="$DOT_DEN/.amazonq/global_context.json"
TARGET_CONFIG="$HOME/.aws/amazonq/global_context.json"

echo "Setting up Amazon Q global knowledge base..."

# Check if source exists
if [ ! -d "$SOURCE_KNOWLEDGE" ]; then
    echo "❌ No knowledge directory found at $SOURCE_KNOWLEDGE"
    exit 1
fi

if [ ! -f "$SOURCE_CONFIG" ]; then
    echo "❌ No global context config found at $SOURCE_CONFIG"
    exit 1
fi

# Handle existing knowledge directory
if [ -e "$TARGET_KNOWLEDGE" ] && [ ! -L "$TARGET_KNOWLEDGE" ]; then
    # Backup existing knowledge
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$HOME/.amazonq/experimental-knowledge.backup.$TIMESTAMP"
    echo "Preserving existing experimental knowledge to $BACKUP_DIR"
    mv "$TARGET_KNOWLEDGE" "$BACKUP_DIR"
    echo "Experimental knowledge preserved. Consider making a PR to add useful content to dotfiles repo"
fi

# Create parent directories
mkdir -p "$(dirname "$TARGET_KNOWLEDGE")"
mkdir -p "$(dirname "$TARGET_CONFIG")"

# Remove existing symlink if present
[ -L "$TARGET_KNOWLEDGE" ] && rm "$TARGET_KNOWLEDGE"

# Create symlink
ln -s "$SOURCE_KNOWLEDGE" "$TARGET_KNOWLEDGE"
echo "✅ Amazon Q global knowledge base symlinked"

# Copy global context config
cp "$SOURCE_CONFIG" "$TARGET_CONFIG"
echo "✅ Global context configuration installed"

# Validate
if [ -L "$TARGET_KNOWLEDGE" ] && [ -f "$TARGET_CONFIG" ]; then
    echo "✅ Amazon Q global rules setup complete"
else
    echo "❌ Setup validation failed!"
    exit 1
fi