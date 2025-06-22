# Logging Framework Usage

All shell scripts in this repository MUST use the standardized logging framework.

## Implementation

```bash
# Source at the top of your script (globally available after setup.sh)
source ~/bin/logging.sh

# Or if you need a fallback for scripts run before setup:
if [[ -f ~/bin/logging.sh ]]; then
    source ~/bin/logging.sh
else
    # Fallback to relative path
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "${SCRIPT_DIR}/../utils/logging.sh"
fi
```

## Functions

- `log_info "message"` - Information (blue [i])
- `log_success "message"` - Success (green [✓])
- `log_warning "message"` - Warning (yellow [!])
- `log_error "message"` - Error (red [✗])
- `log_debug "message"` - Debug (only when DEBUG=1)

## Benefits

- Consistent output formatting
- Token-efficient short prefixes
- Color-coded severity levels
- Debug mode support
- No inline color definitions needed

## Migration

Replace inline echo statements:
```bash
# Bad
echo -e "${GREEN}✓ Success${NC}"

# Good
log_success "Success"
```

Principle: systems-stewardship