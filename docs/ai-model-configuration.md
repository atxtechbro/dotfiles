# AI Provider Model Configuration

| Provider | Global Config | Method | Example | Notes |
|----------|--------------|--------|---------|-------|
| Amazon Q | ✅ Easy | `q settings chat.defaultModel` | `q settings chat.defaultModel claude-4-sonnet` | System-wide setting |
| Claude Code | ⚠️ Limited | `export CLAUDE_MODEL=` | `export CLAUDE_MODEL=claude-opus-4-20250514` | Prefer env var |
| Claude Code (alt) | ⚠️ Less Reliable | `claude config set` | `claude config set model claude-opus-4-20250514` | Per-machine setting |

## Quick Start
- Amazon Q: Run CLI command to set globally
- Claude Code: Use environment variable in `~/.bash_exports`