#!/bin/bash
# Shared version comparison utilities
# Provides normalized version comparison across different tools

# Function to normalize version strings to 3-part semantic versioning
normalize_version() {
    local version="$1"
    
    # Strip common prefixes (v, version, etc.)
    version=$(echo "$version" | sed 's/^[vV]//' | sed 's/^version //')
    
    # Extract just the version number (remove any suffixes like -beta, dates, etc.)
    version=$(echo "$version" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
    
    # Count dots to determine current format
    local dot_count=$(echo "$version" | tr -cd '.' | wc -c)
    
    case $dot_count in
        0) echo "$version.0.0" ;;     # "3" -> "3.0.0"
        1) echo "$version.0" ;;       # "3.4" -> "3.4.0" 
        2) echo "$version" ;;         # "3.4.0" -> "3.4.0"
        *) echo "$version" ;;         # Handle edge cases gracefully
    esac
}

# Function to compare semantic versions
# Returns: "newer", "older", or "same"
version_compare() {
    local v1=$(normalize_version "$1")
    local v2=$(normalize_version "$2")
    
    # Handle empty versions
    if [[ -z "$v1" || -z "$v2" ]]; then
        echo "unknown"
        return
    fi
    
    # Convert versions to comparable format (remove dots, pad with zeros)
    local v1_num=$(echo "$v1" | awk -F. '{printf "%03d%03d%03d", $1, $2, $3}')
    local v2_num=$(echo "$v2" | awk -F. '{printf "%03d%03d%03d", $1, $2, $3}')
    
    if [ "$v1_num" -gt "$v2_num" ]; then
        echo "newer"
    elif [ "$v1_num" -lt "$v2_num" ]; then
        echo "older"
    else
        echo "same"
    fi
}

# Function to extract version from common CLI tools
# Usage: extract_version "tool_name" "version_output"
extract_version() {
    local tool="$1"
    local output="$2"
    
    case "$tool" in
        "claude"|"claude-code")
            echo "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
            ;;
        "gh"|"github-cli")
            echo "$output" | head -n 1 | cut -d' ' -f3
            ;;
        "glab"|"gitlab-cli")
            echo "$output" | head -n 1 | grep -oP 'glab \K[0-9]+\.[0-9]+\.[0-9]+'
            ;;
        "tmux")
            echo "$output" | cut -d' ' -f2
            ;;
        *)
            # Generic extraction - try to find version pattern
            echo "$output" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1
            ;;
    esac
}