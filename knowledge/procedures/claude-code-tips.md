# Claude Code Tips

Force multiplier discoveries for 1000x Claude Code productivity. Default to one-liners, but force multipliers that enable exponential productivity gains deserve the space they need - they pay for themselves in tokens.

## Command Execution

- **Non-interactive only**: See `../constraints/physical/claude-non-interactive.md`. Examples: `claude -p setup-token`, `git commit -m "msg"`, `npm install -y`

## Command Line Usage

- **`claude` is aliased**: Our `claude` command includes `--mcp-config` and `--add-dir` flags. For subcommands, use `-p`: `claude -p setup-token`, `claude -p config`, etc.

## Installation & Uninstallation

- **Uninstall**: `npm uninstall -g @anthropic-ai/claude-code`

## Keyboard Shortcuts

- **ThinkPad conversation navigation**: Hold Escape to view conversation history and fork from any previous message. (ThinkPad users: if Fn Lock is on, toggle with Fn+Esc first)