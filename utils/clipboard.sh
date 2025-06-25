#!/bin/bash
# Cross-platform clipboard utility
# Provides consistent clipboard access across macOS and Linux
# Following the "Spilled Coffee Principle" - works the same everywhere

# Detect available clipboard utilities and set global variables
detect_clipboard() {
    if command -v pbcopy >/dev/null 2>&1; then
        # macOS
        export CLIPBOARD_COPY="pbcopy"
        export CLIPBOARD_PASTE="pbpaste"
    elif command -v xclip >/dev/null 2>&1; then
        # Linux with xclip
        export CLIPBOARD_COPY="xclip -selection clipboard"
        export CLIPBOARD_PASTE="xclip -selection clipboard -o"
    elif command -v xsel >/dev/null 2>&1; then
        # Linux with xsel (alternative)
        export CLIPBOARD_COPY="xsel --clipboard --input"
        export CLIPBOARD_PASTE="xsel --clipboard --output"
    else
        # Fallback - no clipboard support
        export CLIPBOARD_COPY="cat"
        export CLIPBOARD_PASTE="echo 'No clipboard utility found'"
        return 1
    fi
    return 0
}

# Copy to clipboard
clipboard_copy() {
    if [[ -z "$CLIPBOARD_COPY" ]]; then
        detect_clipboard || return 1
    fi
    eval "$CLIPBOARD_COPY"
}

# Paste from clipboard
clipboard_paste() {
    if [[ -z "$CLIPBOARD_PASTE" ]]; then
        detect_clipboard || return 1
    fi
    eval "$CLIPBOARD_PASTE"
}

# If script is executed directly, provide command-line interface
# Skip if being sourced or if $0 is a shell name
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] && [[ "$0" != *"/bash" ]] && [[ "$0" != *"/zsh" ]] && [[ "$0" != *"/sh" ]]; then
    case "${1:-}" in
        "copy"|"c")
            clipboard_copy
            ;;
        "paste"|"p")
            clipboard_paste
            ;;
        "detect"|"d")
            detect_clipboard && echo "Clipboard utilities detected: copy='$CLIPBOARD_COPY' paste='$CLIPBOARD_PASTE'"
            ;;
        *)
            echo "Usage: $0 {copy|paste|detect}"
            echo "  copy   - Copy stdin to clipboard"
            echo "  paste  - Paste clipboard to stdout"
            echo "  detect - Show detected clipboard utilities"
            exit 1
            ;;
    esac
else
    # If sourced, just detect clipboard utilities
    detect_clipboard
fi
