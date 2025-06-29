# MCP Client Integration

Procedure for adding new MCP clients to the dotfiles ecosystem.

## Quick Steps

1. **Create installer**: `utils/install-<client>.sh` with setup/update logic
2. **Update AI provider setup**: Add class to `utils/setup-ai-provider-rules.py`
3. **Hook into setup.sh**: Add installation section after Claude Code
4. **Configure MCP path**: Run `mcp/generate-mcp-config.sh` to generate configs in all needed locations
5. **Test integration**: Run setup.sh and verify MCP servers work

## Integration Patterns

- **Symlinks**: For clients supporting directory discovery (Amazon Q)
- **Generated files**: For clients needing specific formats (Claude Code)
- **Config transform**: For clients with different JSON schemas

See full guide: [docs/mcp-client-integration.md](../../docs/mcp-client-integration.md)

Principle: systems-stewardship