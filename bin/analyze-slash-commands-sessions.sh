#!/bin/bash
# Analyze slash command usage with session-level details
# Shows command sessions, tool usage, and execution patterns

LOG_FILE="$HOME/claude-slash-commands.log"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}=== Claude Slash Command Session Analytics ===${NC}"
echo

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No log file found at: $LOG_FILE"
    echo "Commands will be logged once you start using them."
    exit 0
fi

# Session summary
total_sessions=$(grep -c "SESSION_START" "$LOG_FILE" 2>/dev/null || echo "0")
echo -e "${GREEN}Total command sessions:${NC} $total_sessions"
echo

# Commands run
echo -e "${BLUE}Commands run:${NC}"
grep "SESSION_START" "$LOG_FILE" 2>/dev/null | awk -F' \\| ' '{print $4}' | sort | uniq -c | sort -rn | while read count cmd; do
    printf "  %-20s %s sessions\n" "$cmd" "$count"
done || echo "  No sessions found"
echo

# Tool usage across all sessions
echo -e "${BLUE}Top tools used:${NC}"
grep "TOOL_USE" "$LOG_FILE" 2>/dev/null | awk -F' \\| ' '{print $4}' | sort | uniq -c | sort -rn | head -10 | while read count tool; do
    printf "  %-30s %s\n" "$tool" "$count"
done || echo "  No tool usage found"
echo

# Bash commands
echo -e "${BLUE}Top bash commands:${NC}"
grep "BASH_CMD" "$LOG_FILE" 2>/dev/null | awk -F' \\| ' '{print $4}' | sort | uniq -c | sort -rn | head -10 | while read count cmd; do
    printf "  %-30s %s\n" "$cmd" "$count"
done || echo "  No bash commands found"
echo

# Most recent session details
echo -e "${BLUE}Most recent session:${NC}"
last_session=$(grep "SESSION_START" "$LOG_FILE" 2>/dev/null | tail -1 | awk -F' \\| ' '{print $3}')
if [[ -n "$last_session" ]]; then
    echo "  Session ID: $last_session"
    echo "  Tools used:"
    grep "TOOL_USE.*$last_session" "$LOG_FILE" 2>/dev/null | awk -F' \\| ' '{print "    - " $4}' | sort | uniq -c | sort -rn || echo "    None"
    echo "  Bash commands:"
    grep "BASH_CMD.*$last_session" "$LOG_FILE" 2>/dev/null | awk -F' \\| ' '{print "    - " $4}' | sort | uniq || echo "    None"
else
    echo "  No sessions found"
fi