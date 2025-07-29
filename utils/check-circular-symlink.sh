#!/bin/bash

# =========================================================
# CIRCULAR SYMLINK DIAGNOSTIC TOOL
# =========================================================
# PURPOSE: Monitor for the circular symlink at commands/templates/templates
# This helps track when and how it gets created (issue #1057)
# =========================================================

set -euo pipefail

# Get the dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
CIRCULAR_SYMLINK="$DOTFILES_DIR/commands/templates/templates"
LOG_FILE="$HOME/circular-symlink-monitor.log"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log with timestamp
log_event() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp: $message" >> "$LOG_FILE"
}

# Function to check for circular symlink
check_symlink() {
    if [[ -L "$CIRCULAR_SYMLINK" ]]; then
        # It exists - log details
        local target=$(readlink "$CIRCULAR_SYMLINK")
        local details="Circular symlink FOUND: $CIRCULAR_SYMLINK -> $target"
        echo -e "${RED}✗${NC} $details"
        log_event "$details"
        
        # Log additional context
        log_event "  Current directory: $(pwd)"
        log_event "  Running user: $(whoami)"
        log_event "  Parent process: $(ps -p $PPID -o comm=)"
        
        # Check if any Claude Code processes are running
        if pgrep -f "claude" > /dev/null; then
            log_event "  Claude Code process detected"
        fi
        
        return 1
    else
        echo -e "${GREEN}✓${NC} No circular symlink found"
        return 0
    fi
}

# Function to monitor continuously
monitor_mode() {
    echo "Monitoring for circular symlink (press Ctrl+C to stop)..."
    echo "Logging to: $LOG_FILE"
    log_event "=== Monitor started ==="
    
    while true; do
        if ! check_symlink; then
            echo -e "${YELLOW}→ Detected at $(date '+%H:%M:%S')${NC}"
        fi
        sleep 5
    done
}

# Main script
case "${1:-check}" in
    check)
        echo "Checking for circular symlink..."
        check_symlink
        ;;
    monitor)
        monitor_mode
        ;;
    clean)
        echo "Cleaning up circular symlink if it exists..."
        if [[ -L "$CIRCULAR_SYMLINK" ]]; then
            rm -f "$CIRCULAR_SYMLINK"
            echo -e "${GREEN}✓${NC} Circular symlink removed"
            log_event "Circular symlink manually removed"
        else
            echo "No circular symlink to clean"
        fi
        ;;
    *)
        echo "Usage: $0 [check|monitor|clean]"
        echo "  check   - Check once for circular symlink (default)"
        echo "  monitor - Monitor continuously every 5 seconds"
        echo "  clean   - Remove circular symlink if it exists"
        exit 1
        ;;
esac