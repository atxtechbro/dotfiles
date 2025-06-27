#!/bin/bash
# Analyze slash command usage from log file
# Shows usage patterns and statistics

LOG_FILE="$HOME/claude-slash-commands.log"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}=== Claude Slash Command Analytics ===${NC}"
echo

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No log file found at: $LOG_FILE"
    echo "Commands will be logged once you start using them."
    exit 0
fi

# Total usage count
total_count=$(wc -l < "$LOG_FILE")
echo -e "${GREEN}Total commands used:${NC} $total_count"
echo

# Usage by command
echo -e "${BLUE}Usage by command:${NC}"
awk -F' \\| ' '{print $2}' "$LOG_FILE" | sort | uniq -c | sort -rn | while read count cmd; do
    printf "  %-20s %s\n" "$cmd" "$count"
done
echo

# Usage by date
echo -e "${BLUE}Usage by date:${NC}"
awk -F' ' '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10 | while read count date; do
    printf "  %-12s %s\n" "$date" "$count"
done
echo

# Most recent commands
echo -e "${BLUE}Most recent commands:${NC}"
tail -5 "$LOG_FILE" | while IFS='|' read -r timestamp cmd args; do
    echo "  $timestamp |$cmd"
done
echo

# Commands with arguments
echo -e "${BLUE}Commands with arguments:${NC}"
grep -v " | $" "$LOG_FILE" | tail -5 | while IFS='|' read -r timestamp cmd args; do
    echo "  $cmd |$args"
done