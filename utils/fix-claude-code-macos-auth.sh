#!/usr/bin/env bash
# Fix Claude Code macOS authentication issues
# Addresses: https://github.com/anthropics/claude-code/issues/3566
#
# Usage:
#   ./fix-claude-code-macos-auth.sh          # Run the fix
#   ./fix-claude-code-macos-auth.sh --verify # Verify if Opus is accessible
#   ./fix-claude-code-macos-auth.sh --rollback # Restore from backup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="$HOME/.claude-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function to print colored output
print_step() {
    echo -e "${BLUE}📌 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup a file or directory
backup_item() {
    local item="$1"
    local backup_name="$2"
    
    if [ -e "$item" ]; then
        mkdir -p "$BACKUP_DIR/$TIMESTAMP"
        cp -R "$item" "$BACKUP_DIR/$TIMESTAMP/$backup_name"
        echo "  Backed up: $item"
    fi
}

# Function to verify Opus access
verify_opus_access() {
    print_step "Verifying Claude Code Opus access..."
    
    if ! command_exists claude; then
        print_error "Claude Code is not installed"
        return 1
    fi
    
    # Try to get the model list
    local model_output=$(claude --model opus 2>&1 || true)
    
    if echo "$model_output" | grep -q "Invalid model.*Pro users"; then
        print_error "Opus is NOT accessible - still seeing Pro user error"
        echo "$model_output"
        return 1
    elif echo "$model_output" | grep -q "Set model to opus"; then
        print_success "Opus model is accessible!"
        return 0
    else
        print_warning "Unable to determine Opus accessibility"
        echo "Output: $model_output"
        return 2
    fi
}

# Function to rollback from backup
rollback_from_backup() {
    print_step "Rolling back Claude Code configuration..."
    
    # Find the latest backup
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No backups found in $BACKUP_DIR"
        exit 1
    fi
    
    local latest_backup=$(ls -t "$BACKUP_DIR" | head -1)
    if [ -z "$latest_backup" ]; then
        print_error "No backups found"
        exit 1
    fi
    
    local backup_path="$BACKUP_DIR/$latest_backup"
    echo "Using backup from: $latest_backup"
    
    # Restore backed up files
    if [ -f "$backup_path/claude.json" ]; then
        cp "$backup_path/claude.json" "$HOME/.claude.json"
        print_success "Restored ~/.claude.json"
    fi
    
    if [ -d "$backup_path/claude-dir" ]; then
        rm -rf "$HOME/.claude"
        cp -R "$backup_path/claude-dir" "$HOME/.claude"
        print_success "Restored ~/.claude directory"
    fi
    
    # Remove environment variables
    for config_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
        if [ -f "$config_file" ]; then
            # Remove the Claude Code macOS fix section
            sed -i.bak '/# Claude Code macOS fix/,+3d' "$config_file" 2>/dev/null || \
            sed -i '' '/# Claude Code macOS fix/,+3d' "$config_file" 2>/dev/null || true
        fi
    done
    
    print_success "Rollback completed!"
    echo ""
    echo "Please restart your terminal or run:"
    echo "  source ~/.bashrc  # or ~/.zshrc"
}

# Main fix function
run_fix() {
    echo "🔧 Claude Code macOS Authentication Fix Script"
    echo "============================================="
    echo "This script will attempt multiple fixes for the Opus model access issue"
    echo ""
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "This script is designed for macOS. Detected: $OSTYPE"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    # 1. Backup current configuration
    print_step "Step 1: Backing up current configuration..."
    backup_item "$HOME/.claude.json" "claude.json"
    backup_item "$HOME/.claude" "claude-dir"
    
    # 2. Clear keychain entries
    print_step "Step 2: Clearing macOS Keychain entries..."
    security delete-generic-password -s "Claude Code" 2>/dev/null || echo "  No 'Claude Code' keychain entry found (this is OK)"
    security delete-generic-password -s "Claude Code-credentials" 2>/dev/null || echo "  No 'Claude Code-credentials' entry found (this is OK)"
    
    # 3. Remove potentially corrupted config
    print_step "Step 3: Removing Claude config files..."
    rm -f ~/.claude.json
    rm -rf ~/.claude/
    print_success "Removed Claude configuration files"
    
    # 4. Clear all Claude Code installations
    print_step "Step 4: Removing all Claude Code installations..."
    if command_exists npm; then
        npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
    fi
    
    # Find and remove all node_modules installations
    if [ -d ~/.nvm/versions/node ]; then
        find ~/.nvm/versions/node -name "@anthropic-ai" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
    [ -d /usr/local/lib/node_modules ] && \
        find /usr/local/lib/node_modules -name "@anthropic-ai" -type d -exec rm -rf {} + 2>/dev/null || true
    [ -d /opt/homebrew/lib/node_modules ] && \
        find /opt/homebrew/lib/node_modules -name "@anthropic-ai" -type d -exec rm -rf {} + 2>/dev/null || true
    print_success "Removed all Claude Code installations"
    
    # 5. Set environment variables to prevent Bedrock interference
    print_step "Step 5: Setting environment variables..."
    export CLAUDE_USE_BEDROCK=false
    export DISABLE_BEDROCK=true
    export CLAUDE_CODE_USE_BEDROCK=false
    
    # Determine shell config file
    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi
    
    # Add to shell config if not already present
    if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
        if ! grep -q "CLAUDE_USE_BEDROCK=false" "$SHELL_CONFIG"; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Claude Code macOS fix" >> "$SHELL_CONFIG"
            echo "export CLAUDE_USE_BEDROCK=false" >> "$SHELL_CONFIG"
            echo "export DISABLE_BEDROCK=true" >> "$SHELL_CONFIG"
            echo "export CLAUDE_CODE_USE_BEDROCK=false" >> "$SHELL_CONFIG"
            print_success "Added environment variables to $SHELL_CONFIG"
        else
            echo "  Environment variables already present in $SHELL_CONFIG"
        fi
    fi
    
    # 6. Reinstall Claude Code
    print_step "Step 6: Reinstalling Claude Code..."
    if command_exists npm; then
        npm install -g @anthropic-ai/claude-code@latest
        print_success "Claude Code reinstalled successfully"
    else
        print_error "npm not found. Please install Node.js first."
        echo "You can install Node.js via:"
        echo "  - nvm: https://github.com/nvm-sh/nvm"
        echo "  - Homebrew: brew install node"
        echo "  - Download: https://nodejs.org/"
        exit 1
    fi
    
    # 7. Final instructions
    echo ""
    print_success "Fix script completed!"
    echo ""
    echo "🔄 IMPORTANT NEXT STEPS:"
    echo "   1. Restart your machine (recommended) OR"
    echo "      - Close all terminal windows and reopen"
    echo "      - Run: source $SHELL_CONFIG"
    echo ""
    echo "   2. After restart/reload:"
    echo "      a. Run 'claude' in terminal"
    echo "      b. Log in with your Claude Max account"
    echo "      c. Run './fix-claude-code-macos-auth.sh --verify' to check Opus access"
    echo ""
    echo "If the issue persists after restart, the bug is in Claude Code itself"
    echo "and requires a fix from Anthropic (tracked in issue #3566)"
    echo ""
    echo "Backups saved to: $BACKUP_DIR/$TIMESTAMP"
}

# Parse command line arguments
case "${1:-}" in
    --verify|-v)
        verify_opus_access
        ;;
    --rollback|-r)
        rollback_from_backup
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  (no options)     Run the fix script"
        echo "  --verify, -v     Verify if Opus model is accessible"
        echo "  --rollback, -r   Rollback to the latest backup"
        echo "  --help, -h       Show this help message"
        ;;
    *)
        run_fix
        ;;
esac