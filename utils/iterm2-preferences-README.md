# iTerm2 Preferences Management

## Overview
We use a template-based approach for iTerm2 configuration. Instead of trying to construct preferences programmatically, we capture a known-good configuration and apply it wholesale.

## Important: Restart Required
**Unlike manual preference changes in the iTerm2 UI (which take effect immediately), programmatic changes require restarting iTerm2.**

When you run the configuration script:
1. Preferences are written to disk
2. `cfprefsd` is reloaded
3. **But iTerm2 must be restarted to read the new preferences**

This is why manual changes work instantly but our script requires a restart.

## Why This Approach?
1. **Completeness**: iTerm2 has hundreds of preference keys. Missing any can cause unexpected behavior.
2. **Reliability**: Captures all interdependencies between settings.
3. **Simplicity**: No need to reverse-engineer iTerm2's preference format.
4. **Maintainability**: Easy to update - just export new preferences when needed.

## Previous Broken Approach
The script used to do:
```bash
defaults delete com.googlecode.iterm2 2>/dev/null || true
```
This tried to delete ALL iTerm2 preferences, then write back only a profile. This didn't work because:
- iTerm2 needs many other preference keys to function
- The delete command was failing silently due to `|| true`
- Even the mouse settings we added were ignored without the full preference context

## Updating the Template
1. Configure iTerm2 exactly how you want it
2. Export current preferences:
   ```bash
   defaults read com.googlecode.iterm2 > utils/iterm2-preferences.plist
   ```
3. Commit the updated template

## Key Settings in Our Template
- **Mouse Reporting**: Enabled for tmux pane selection
- **Terminal Type**: xterm-256color
- **Profile Name**: TmuxDev
- **Window Size**: 140x45
- **Font**: Monaco 14pt
- **Option Keys**: Send Esc+ (for tmux navigation)