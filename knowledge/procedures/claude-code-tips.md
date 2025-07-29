# Claude Code Tips

Force multiplier discoveries for 1000x Claude Code productivity. Default to one-liners, but force multipliers that enable exponential productivity gains deserve the space they need - they pay for themselves in tokens.

## Command Execution

- **Non-interactive only**: See `non-interactive-execution.md`. Examples: `claude -p setup-token`, `git commit -m "msg"`, `npm install -y`

## Installation & Uninstallation

- **Uninstall**: `npm uninstall -g @anthropic-ai/claude-code`

## Keyboard Shortcuts

- **ThinkPad conversation navigation**: Hold Escape to view conversation history and fork from any previous message. (ThinkPad users: if Fn Lock is on, toggle with Fn+Esc first)

## MCP Server Permissions

- **No wildcards**: Use server names only in permissions (e.g., `"mcp__git"` not `"mcp__git*"`) - wildcards aren't supported despite appearing to work for servers without hyphens

## Model Configuration

- **Set in settings.json**: Configure with `"model": "claude-opus-4-20250514"`

## Permission Systems (Validated)

Claude Code has two separate permission systems that behave differently:

### 1. Built-in Tool Permissions
- **Managed by**: `/permissions` command at runtime
- **Covers**: Edit, Write, Read, Bash commands
- **Changes**: Take effect immediately without restart
- **View current state**: Type `/permissions` to see Allow/Deny/Workspace tabs

### 2. MCP Server Permissions  
- **Managed by**: `settings.json` file
- **Covers**: `mcp__git`, `mcp__github-read`, `mcp__filesystem`, etc.
- **Changes**: Only loaded at session start (requires restart)
- **Confirmed limitation**: Granular permissions don't work - only server-level permissions are supported
  - ❌ `mcp__github-write__create_pull_request` - doesn't work
  - ❌ `mcp__git__git_push` - doesn't work  
  - ✅ `mcp__github-write` - works (all-or-nothing for the server)
  - ✅ `mcp__git` - works (all-or-nothing for the server)

### Runtime Workspace Access
- **The `/permissions` Workspace tab** = runtime equivalent of `additionalDirectories`
- Add `/` to grant full filesystem access without restarting
- Changes take effect immediately for Edit/Write tools

### Quick Testing Tips
- **The symlink trick**: `~/.claude/settings.json` is symlinked to the source-controlled version
  - Edit it directly for instant testing (affects git repo)
  - Changes to MCP permissions still require restart
- **Use `/permissions` as a REPL**: Experiment with built-in tool permissions in real-time