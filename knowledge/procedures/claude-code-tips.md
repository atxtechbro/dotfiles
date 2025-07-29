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