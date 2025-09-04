#!/bin/bash
# Sync and cleanup Claude commands
# Detects orphaned commands and manages command lifecycle
# Principles: systems-stewardship, subtraction-creates-value

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Command directories
GLOBAL_COMMANDS="$HOME/.claude/commands"
PROJECT_COMMANDS=".claude/commands"
TEMPLATE_DIR="$DOTFILES_DIR/.claude/command-templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Operation mode
MODE="check" # Default to check mode
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            MODE="clean"
            shift
            ;;
        --check)
            MODE="check"
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            cat << EOF
Usage: $(basename "$0") [OPTIONS]

Sync and cleanup Claude commands between templates and generated files.

Options:
    --check     Check for orphaned commands (default)
    --clean     Remove orphaned commands
    --verbose   Show detailed output
    --help      Show this help message

This tool:
1. Detects orphaned commands (those without corresponding templates)
2. Identifies missing generated commands
3. Reports conflicts between global and project commands
4. Cleans up commands that are no longer needed

Principles:
- systems-stewardship: Single source of truth for commands
- subtraction-creates-value: Remove unnecessary clutter
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Function to log messages
log() {
    local level="$1"
    shift
    case "$level" in
        error)
            echo -e "${RED}✗${NC} $*" >&2
            ;;
        success)
            echo -e "${GREEN}✓${NC} $*"
            ;;
        warning)
            echo -e "${YELLOW}⚠${NC} $*"
            ;;
        info)
            if [[ "$VERBOSE" == "true" ]]; then
                echo "  $*"
            fi
            ;;
        *)
            echo "$*"
            ;;
    esac
}

# Check if directories exist
check_directories() {
    local dirs_exist=true
    
    if [[ ! -d "$TEMPLATE_DIR" ]]; then
        log warning "Template directory not found: $TEMPLATE_DIR"
        dirs_exist=false
    fi
    
    if [[ ! -d "$GLOBAL_COMMANDS" ]]; then
        log info "Global commands directory not found: $GLOBAL_COMMANDS"
        log info "Creating directory..."
        mkdir -p "$GLOBAL_COMMANDS"
    fi
    
    if [[ "$dirs_exist" == "false" ]]; then
        return 1
    fi
    
    return 0
}

# Get list of template-based commands
get_template_commands() {
    local templates=()
    if [[ -d "$TEMPLATE_DIR" ]]; then
        for template in "$TEMPLATE_DIR"/*.md; do
            if [[ -f "$template" ]]; then
                local cmd_name=$(basename "$template")
                templates+=("$cmd_name")
            fi
        done
    fi
    printf '%s\n' "${templates[@]}"
}

# Get list of generated commands
get_generated_commands() {
    local commands=()
    if [[ -d "$GLOBAL_COMMANDS" ]]; then
        for command in "$GLOBAL_COMMANDS"/*.md; do
            if [[ -f "$command" ]]; then
                local cmd_name=$(basename "$command")
                # Skip README files
                if [[ "$cmd_name" != "README"* ]]; then
                    commands+=("$cmd_name")
                fi
            fi
        done
    fi
    printf '%s\n' "${commands[@]}"
}

# Find orphaned commands (generated but no template)
find_orphaned_commands() {
    local orphaned=()
    local generated_cmds=($(get_generated_commands))
    local template_cmds=($(get_template_commands))
    
    for gen_cmd in "${generated_cmds[@]}"; do
        local found=false
        for tmpl_cmd in "${template_cmds[@]}"; do
            if [[ "$gen_cmd" == "$tmpl_cmd" ]]; then
                found=true
                break
            fi
        done
        
        if [[ "$found" == "false" ]]; then
            orphaned+=("$gen_cmd")
        fi
    done
    
    printf '%s\n' "${orphaned[@]}"
}

# Find missing commands (template exists but not generated)
find_missing_commands() {
    local missing=()
    local generated_cmds=($(get_generated_commands))
    local template_cmds=($(get_template_commands))
    
    for tmpl_cmd in "${template_cmds[@]}"; do
        local found=false
        for gen_cmd in "${generated_cmds[@]}"; do
            if [[ "$tmpl_cmd" == "$gen_cmd" ]]; then
                found=true
                break
            fi
        done
        
        if [[ "$found" == "false" ]]; then
            missing+=("$tmpl_cmd")
        fi
    done
    
    printf '%s\n' "${missing[@]}"
}

# Check for conflicts between global and project commands
check_conflicts() {
    local conflicts=()
    
    if [[ -d "$PROJECT_COMMANDS" ]] && [[ -d "$GLOBAL_COMMANDS" ]]; then
        for proj_cmd in "$PROJECT_COMMANDS"/*.md; do
            if [[ -f "$proj_cmd" ]]; then
                local cmd_name=$(basename "$proj_cmd")
                if [[ -f "$GLOBAL_COMMANDS/$cmd_name" ]]; then
                    conflicts+=("$cmd_name")
                fi
            fi
        done
    fi
    
    printf '%s\n' "${conflicts[@]}"
}

# Clean orphaned commands
clean_orphaned_commands() {
    local orphaned=($(find_orphaned_commands))
    local count=0
    
    if [[ ${#orphaned[@]} -eq 0 ]]; then
        log success "No orphaned commands to clean"
        return 0
    fi
    
    log warning "Found ${#orphaned[@]} orphaned command(s)"
    
    for cmd in "${orphaned[@]}"; do
        local cmd_path="$GLOBAL_COMMANDS/$cmd"
        if [[ -f "$cmd_path" ]]; then
            log info "Removing: $cmd"
            rm -f "$cmd_path"
            ((count++))
        fi
    done
    
    log success "Cleaned $count orphaned command(s)"
}

# Main execution
main() {
    echo "Claude Command Sync Tool"
    echo "========================"
    echo
    
    # Check directories
    if ! check_directories; then
        log error "Required directories not found"
        exit 1
    fi
    
    if [[ "$MODE" == "check" ]]; then
        echo "Checking command status..."
        echo
        
        # Find orphaned commands
        orphaned=($(find_orphaned_commands))
        if [[ ${#orphaned[@]} -gt 0 ]]; then
            log warning "Orphaned commands (no template):"
            for cmd in "${orphaned[@]}"; do
                echo "    - $cmd"
            done
            echo
        else
            log success "No orphaned commands found"
        fi
        
        # Find missing commands
        missing=($(find_missing_commands))
        if [[ ${#missing[@]} -gt 0 ]]; then
            log warning "Missing generated commands (template exists):"
            for cmd in "${missing[@]}"; do
                echo "    - $cmd"
            done
            echo
        else
            log success "All templates have generated commands"
        fi
        
        # Check for conflicts
        conflicts=($(check_conflicts))
        if [[ ${#conflicts[@]} -gt 0 ]]; then
            log warning "Conflicting commands (exist in both global and project):"
            for cmd in "${conflicts[@]}"; do
                echo "    - $cmd"
            done
            echo
        fi
        
        # Summary
        echo "Summary:"
        echo "  Templates: $(get_template_commands | wc -l)"
        echo "  Generated: $(get_generated_commands | wc -l)"
        echo "  Orphaned:  ${#orphaned[@]}"
        echo "  Missing:   ${#missing[@]}"
        echo "  Conflicts: ${#conflicts[@]}"
        
        if [[ ${#orphaned[@]} -gt 0 ]]; then
            echo
            echo "Run with --clean to remove orphaned commands"
        fi
        
        # Exit with error if issues found
        if [[ ${#orphaned[@]} -gt 0 ]] || [[ ${#missing[@]} -gt 0 ]]; then
            exit 1
        fi
        
    elif [[ "$MODE" == "clean" ]]; then
        echo "Cleaning orphaned commands..."
        echo
        clean_orphaned_commands
    fi
    
    echo
    log success "Done!"
}

# Run main
main