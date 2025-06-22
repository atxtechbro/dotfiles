#!/bin/bash
# Common logging functions for installation scripts
# This provides consistent logging across all installation utilities

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log an informational message
# Usage: log_info "Your message here"
log_info() {
# Log an informational message
# Usage: log_info "Your message here"
log_info() {
    printf "${BLUE}[INFO]${NC} %s
" "$1"
}

# Log a success message
# Usage: log_success "Your message here"
log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s
" "$1"
}

# Log a warning message
# Usage: log_warning "Your message here"
log_warning() {
    printf "${YELLOW}[WARNING]${NC} %s
" "$1"
}

# Log an error message
# Usage: log_error "Your message here"
log_error() {
    printf "${RED}[ERROR]${NC} %s
" "$1"
}
}

# Log a success message
# Usage: log_success "Your message here"
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Log a warning message
# Usage: log_warning "Your message here"
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Log an error message
# Usage: log_error "Your message here"
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Log a debug message (only shown if DEBUG=1)
# Usage: log_debug "Your message here"
log_debug() {
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} ${1}"
}

# Log a warning message
# Usage: log_warning "Your message here"
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} ${1}"
}

# Log an error message
# Usage: log_error "Your message here"
log_error() {
    echo -e "${RED}[ERROR]${NC} ${1}"
}

# Log a debug message (only shown if DEBUG=1)
# Usage: log_debug "Your message here"
log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "[DEBUG] ${1}"
    fi
}
        echo -e "[DEBUG] $1"
    fi
}