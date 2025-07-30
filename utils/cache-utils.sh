#!/bin/bash
# Cache utilities for dotfiles setup optimization
# Provides functions to track installations and avoid redundant operations

# Cache directory for tracking installations
CACHE_DIR="$HOME/.dotfiles-setup-cache"
mkdir -p "$CACHE_DIR"

# Get cache file path for a component
get_cache_file() {
    local component="$1"
    echo "$CACHE_DIR/${component}.cache"
}

# Check if a component was installed/configured recently
is_cached() {
    local component="$1"
    local max_age_days="${2:-7}"  # Default 7 days
    local cache_file=$(get_cache_file "$component")
    
    if [[ ! -f "$cache_file" ]]; then
        return 1  # Not cached
    fi
    
    # Check age of cache file
    local cache_age_seconds=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)))
    local max_age_seconds=$((max_age_days * 86400))
    
    if [[ $cache_age_seconds -gt $max_age_seconds ]]; then
        return 1  # Cache expired
    fi
    
    return 0  # Cached and valid
}

# Mark a component as installed/configured
mark_cached() {
    local component="$1"
    local cache_file=$(get_cache_file "$component")
    local version="${2:-unknown}"
    
    echo "version=$version" > "$cache_file"
    echo "timestamp=$(date +%s)" >> "$cache_file"
    echo "date=$(date)" >> "$cache_file"
}

# Get cached version info
get_cached_version() {
    local component="$1"
    local cache_file=$(get_cache_file "$component")
    
    if [[ -f "$cache_file" ]]; then
        grep "^version=" "$cache_file" 2>/dev/null | cut -d= -f2
    fi
}

# Clear cache for a component
clear_cache() {
    local component="$1"
    local cache_file=$(get_cache_file "$component")
    rm -f "$cache_file"
}

# Clear all cache
clear_all_cache() {
    echo "Clearing all setup cache..."
    rm -rf "$CACHE_DIR"
    mkdir -p "$CACHE_DIR"
}

# Check if a command needs updating based on version
needs_update() {
    local command="$1"
    local current_version="$2"
    local cached_version=$(get_cached_version "$command")
    
    # If no cached version, needs update
    if [[ -z "$cached_version" ]]; then
        return 0
    fi
    
    # If versions differ, needs update
    if [[ "$current_version" != "$cached_version" ]]; then
        return 0
    fi
    
    return 1  # No update needed
}

# Cache-aware command execution
cached_execute() {
    local cache_key="$1"
    local cache_days="${2:-7}"
    shift 2
    local command=("$@")
    
    if is_cached "$cache_key" "$cache_days"; then
        echo "✓ $cache_key already configured (cached)"
        return 0
    fi
    
    echo "→ Configuring $cache_key..."
    if "${command[@]}"; then
        mark_cached "$cache_key"
        return 0
    else
        return 1
    fi
}

# Export functions for use in other scripts
export -f get_cache_file
export -f is_cached
export -f mark_cached
export -f get_cached_version
export -f clear_cache
export -f clear_all_cache
export -f needs_update
export -f cached_execute