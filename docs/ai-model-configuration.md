# AI Provider Model Configuration

| Provider | Global Config | Method | Example | Notes |
|----------|--------------|--------|---------|-------|
| Amazon Q | ✅ Easy | CLI command | `q settings chat.defaultModel claude-4-sonnet` | System-wide setting |
| Claude Code | ✅ Persistent | Settings file | `"model": "<model-name>"` in `~/.claude/settings.json` | See [official model names](https://docs.anthropic.com/en/docs/about-claude/models/overview#model-names) |
| Claude Code | ✅ Per-session | Command flag | `claude --model <model-name>` | Override default for specific session |

## Quick Start
- **Amazon Q**: Run CLI command to set globally
- **Claude Code**: Configure in `~/.claude/settings.json` or use `--model` flag for one-off sessions

## Notes
- `WORK_MACHINE` environment variable controls MCP server availability, not model selection
- Claude Code model selection is explicit, not automatic based on machine type