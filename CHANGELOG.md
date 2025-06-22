# Changelog

A living log of notable changes, decisions, and modifications to the dotfiles setup.

## 2025-06-22

- **Claude Code Integration**: Added Claude Code CLI support after purchasing Claude Max plan
- Created `utils/install-claude-code.sh` - automated installation/update with MCP server configuration (Spilled Coffee)
- Integrated Claude Code into setup.sh alongside Amazon Q - true LLM provider agnosticism (Invent and Simplify)
- MCP servers configured via simple copy to `~/.mcp.json` - same approach as Amazon Q (Subtraction Creates Value)
- Added `mcp-client-integration.md` procedure - documented pattern for adding new MCP clients (Systems Stewardship)
- Global context already working via existing `setup-ai-provider-rules.py` - no changes needed

## 2025-06-21

- **Performance Win**: Fixed tmux frequent upgrade prompts - 40% faster setup.sh execution by only upgrading when updates are actually available (17ea3a6)

## 2025-06-19

- Restructured Amazon Q rules to vendor-neutral knowledge taxonomy (#487) - enables tool-agnostic knowledge organization (Invent and Simplify, Systems Stewardship)
- Added CHANGELOG.md for documenting notable changes and decisions (Snowball Method)
- Commented out Claude Desktop setups - no longer using, made reintegration seamless (Subtraction Creates Value)

## Format

- One line per change, max 120 characters
- Include principle in parentheses when relevant
- Focus on what changed and why, not implementation details
