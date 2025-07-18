# Amazon Q Prompts (Claude Code Slash Command Equivalent)

Amazon Q uses **prompts** instead of slash commands. These are provided by MCP servers and work similarly to Claude Code's slash commands but with different syntax.

## Key Differences from Claude Code

| Claude Code | Amazon Q | Notes |
|-------------|----------|-------|
| `/close-issue 934` | `@close-issue 934` | Use `@` prefix instead of `/` |
| `/prompts` | `/prompts` | List available prompts |
| Direct execution | `@prompt-name args` | Must use `@` prefix for execution |

## Available Prompts

After running `q` and loading MCP servers, use `/prompts` to see available prompts:

```
> /prompts

Prompt                             Arguments (* = required)
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
git (MCP):
- close-issue                      issue_number*
- commit-message                   commit_count
- pr-description                   base_branch

github_read (MCP):
- AssignCodingAgent                repo*

github_write (MCP):
- AssignCodingAgent                repo*
```

## Usage Examples

### Close Issue Workflow
```bash
# In Amazon Q chat
> @close-issue 934
```

### Generate Commit Message
```bash
# In Amazon Q chat
> @commit-message 3
```

### Generate PR Description
```bash
# In Amazon Q chat
> @pr-description main
```

## Setup Requirements

1. **Login**: `q login` (required before first use)
2. **MCP Servers**: Prompts come from MCP servers configured in `mcp/mcp.json`
3. **Context**: Run `q` from your repository root for proper context

## Troubleshooting

### "error: unrecognized subcommand 'close-issue'"
**Problem**: Using `/prompts close-issue` instead of `@close-issue`

**Solution**: 
- Use `/prompts` to LIST available prompts
- Use `@prompt-name args` to EXECUTE prompts

### MCP Servers Not Loading
```
⚠ 5 of 7 mcp servers initialized. Servers still loading:
 - gdrive
 - gitlab
```

This is normal - some servers take longer to initialize. Core functionality (git, github) loads first.

### Login Required
```
error: You are not logged in, please log in with q login
```

Run `q login` and follow the prompts. You'll need your AWS SSO start URL and region.

## Provider Symmetry

Both Claude Code and Amazon Q use the same MCP servers but with different syntax:

- **Claude Code**: `/close-issue 934` (slash commands)
- **Amazon Q**: `@close-issue 934` (prompts with @ prefix)

The underlying functionality is identical - both execute the same MCP server prompts.

## Related Documentation

- [MCP Prompts PoC](../mcp/prompts/README.md) - Technical implementation details
- [AI Provider Agnosticism](../knowledge/principles/ai-provider-agnosticism.md) - Why both providers work identically
- [Slash Command Generation](../knowledge/procedures/slash-command-generation.md) - Claude Code equivalent
