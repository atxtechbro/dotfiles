#!/usr/bin/env bash
#
# sync-plugin-commands.sh
# Syncs procedures from knowledge/procedures/ to commands/ for Claude Code plugin
#
# Claude Code doesn't follow symlinks in the commands directory, so we need
# to copy the actual files. This script maintains the single source of truth
# in knowledge/procedures/ while creating regular files in commands/.
#
# Usage: ./scripts/sync-plugin-commands.sh

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROCEDURES_DIR="$REPO_ROOT/knowledge/procedures"
COMMANDS_DIR="$REPO_ROOT/commands"

echo -e "${YELLOW}Syncing procedures to commands directory...${NC}"

# Create commands directory if it doesn't exist
mkdir -p "$COMMANDS_DIR"

# Track what we sync
SYNCED_COUNT=0
SKIPPED_COUNT=0

# First, remove old symlinks (but keep regular files like test files)
for file in "$COMMANDS_DIR"/*.md; do
    if [ -L "$file" ]; then
        basename_file=$(basename "$file")
        echo -e "${YELLOW}Removing old symlink: $basename_file${NC}"
        rm "$file"
    fi
done

# Sync procedures that have proper frontmatter
for proc in "$PROCEDURES_DIR"/*.md; do
    if [ ! -f "$proc" ]; then
        continue
    fi

    basename_proc=$(basename "$proc")

    # Check if file has description frontmatter (required for commands)
    if grep -q "^description:" "$proc"; then
        # Transform filename: remove "-procedure" suffix if present
        target_name="${basename_proc/-procedure.md/.md}"

        # Special case: if it doesn't end with -procedure.md, use as-is
        if [ "$target_name" = "$basename_proc" ]; then
            target_name="$basename_proc"
        fi

        target_path="$COMMANDS_DIR/$target_name"

        # Copy the file
        cp "$proc" "$target_path"
        echo -e "${GREEN}✓ Synced: $basename_proc → $target_name${NC}"
        ((SYNCED_COUNT++))
    else
        echo -e "${RED}✗ Skipped: $basename_proc (no description frontmatter)${NC}"
        ((SKIPPED_COUNT++))
    fi
done

echo -e "\n${GREEN}Sync complete!${NC}"
echo -e "  ${GREEN}✓ Synced: $SYNCED_COUNT files${NC}"
if [ $SKIPPED_COUNT -gt 0 ]; then
    echo -e "  ${YELLOW}⚠ Skipped: $SKIPPED_COUNT files (no description)${NC}"
fi

# List the commands directory
echo -e "\n${YELLOW}Commands directory contents:${NC}"
ls -la "$COMMANDS_DIR"/*.md 2>/dev/null | tail -n +1 | while read -r line; do
    echo "  $line"
done

echo -e "\n${GREEN}Done! Commands are now ready for Claude Code plugin.${NC}"