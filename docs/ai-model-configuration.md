# AI Provider Model Configuration

| Provider | Global Config | Method | Example | Notes |
|----------|--------------|--------|---------|-------|
| Amazon Q | ✅ Easy | `q settings chat.defaultModel` | `q settings chat.defaultModel claude-4-sonnet` | System-wide setting |
| Claude Code | ✅ Automatic | Alias-based | `WORK_MACHINE="false"` in `~/.bash_exports.local` | Personal machines automatically use Opus |
| Claude Code (manual) | ✅ Per-session | Command flag | `claude --model claude-opus-4-20250514` | Override default for specific session |

## Quick Start
- Amazon Q: Run CLI command to set globally
- Claude Code: Automatically uses Opus on personal machines (when `WORK_MACHINE != "true"`)