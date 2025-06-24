# Testing Terminal Bell Notifications

## Quick Test
```bash
# Test bell directly
printf '\a'

# Test with echo
echo -e '\a'

# Test with tput
tput bel
```

## Testing Claude Code Notifications

### Current Setup
- Claude Code is configured to use `terminal_bell`
- Idle threshold is 60 seconds

### Test Process
1. Start a long-running Claude Code task
2. Wait 60+ seconds after last output
3. You should hear/see a bell notification

### Verifying Configuration
```bash
# Check Claude Code settings
claude config list --global | grep -E "(preferredNotifChannel|messageIdleNotifThresholdMs)"

# Should show:
# "preferredNotifChannel": "terminal_bell",
# "messageIdleNotifThresholdMs": 60000
```

## After PR #524 is Merged

Once the tmux configuration is updated:

```bash
# Apply new tmux config
tmux source-file ~/.tmux.conf

# Or in existing tmux session
# Press prefix (Ctrl-b) then type:
:source-file ~/.tmux.conf
```

## Terminal-Specific Settings

### iTerm2
- Preferences → Profiles → Terminal → Enable "Visual Bell" or "Audible Bell"

### Terminal.app
- Preferences → Profiles → Advanced → Enable "Bell"

### Linux Terminal
- Most terminals have bell enabled by default
- Check preferences for "Terminal Bell" or "System Bell"

## Troubleshooting

If bell doesn't work:
1. Check terminal volume isn't muted
2. Try visual bell if audio doesn't work
3. Switch to desktop notifications: `claude config set --global preferredNotifChannel desktop`