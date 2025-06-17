# macOS-specific aliases and compatibility

# Timeout command compatibility - coreutils provides gtimeout on macOS
if [[ "$OSTYPE" == "darwin"* ]] && command -v gtimeout &> /dev/null && ! command -v timeout &> /dev/null; then
    alias timeout='gtimeout'
fi
