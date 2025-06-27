#!/bin/bash
# Slash command usage logging
# Logs when slash commands are used to track analytics

SLASH_COMMAND_LOG="$HOME/claude-slash-commands.log"

# Log slash command usage
# Usage: log_slash_command "command_name" "args"
log_slash_command() {
    local command_name="$1"
    local args="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Append to log file
    echo "$timestamp | $command_name | $args" >> "$SLASH_COMMAND_LOG"
}

# Export function so it can be used in generated commands
export -f log_slash_command
export SLASH_COMMAND_LOG