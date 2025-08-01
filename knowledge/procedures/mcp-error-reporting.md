# MCP Error Reporting

Procedure for reporting errors with our custom MCP tools to create self-healing systems.

## Core Philosophy

**We control the git and github MCP servers - we'll fix them, not work around them!**

This procedure creates autonomy for AI agents and snowball momentum for increasingly efficient tools.

## When to Use This

When any of our custom MCP tools fail:
- `mcp__git__*` tools (our git server)
- `mcp__github__*` tools (our github server)

**NOT for external tools** like playwright, brave-search, etc.

## Procedure

1. **Continue your task** using a workaround if possible (80/20 rule - focus on core work)

2. **Immediately after finding a workaround**:
   - Check for [existing MCP error issues](https://github.com/atxtechbro/dotfiles/issues?q=is%3Aissue+label%3Amcp-tool-error)
   - If found: Add a comment saying you experienced it too
   - If not found: Create a new issue using the [MCP Tool Error template](https://github.com/atxtechbro/dotfiles/issues/new?template=mcp-tool-error.md)
   - **Don't wait** - report while the error is fresh in context
   - When available, follow [GitHub Issue Creation procedure](github-issue-creation.md) (see [#1100](https://github.com/atxtechbro/dotfiles/issues/1100))

3. **Alert the human** - Claude Code restart may be needed for immediate fix

## Agent Reminder

**Proactively report errors**: When you encounter an MCP tool error, create the issue immediately after finding a workaround. Don't wait for the human to remind you. This is part of creating self-healing systems and giving agents autonomy.

## Why This Matters

- Creates feedback loop for tool improvement
- Documents issues formally for later fixing
- Maintains momentum on core work (80/20 rule)
- Builds self-healing systems through proper issue tracking
- Gives AI agents autonomy instead of helplessness

## Error Report Template

Use the [MCP Tool Error template](/.github/ISSUE_TEMPLATE/mcp-tool-error.md) which includes:
- Tool name
- Expected vs actual behavior
- Error message
- Context
- Workaround used

## Remember

- We built these servers, we can fix them
- Focus 80% on core work, 20% on documenting issues
- Every reported issue makes our tools more joyful
- Human assistance is available for restarts

