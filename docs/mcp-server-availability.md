# MCP Server Availability Guide

## Currently Connected MCP Servers

As of the latest configuration, the following MCP servers are **actually connected and available**:

### ✅ Available
- **playwright** - Browser automation server
  - Functions: `mcp__playwright__*`
  - Capabilities: Browser navigation, clicking, form filling, screenshots, etc.
  - Configuration: See `mcp/mcp.json`

### ❌ NOT Available (Despite Appearing in Tool Approval List)

The following MCP servers appear in Claude Code's internal tool approval list but are **NOT actually connected**:

#### GitHub Write Server
- `mcp__github-write__get_issue`
- `mcp__github-write__get_issue_comments`
- `mcp__github-write__list_pull_requests`
- `mcp__github-write__search_issues`
- `mcp__github-write__search_pull_requests`

**Alternative**: Use `gh` CLI commands via Bash tool instead.

#### Git Server
- `mcp__git__git_worktree_add`
- `mcp__git__git_add`
- `mcp__git__git_commit`
- `mcp__git__git_batch`
- `mcp__git__git_status`
- `mcp__git__git_log`
- `mcp__git__git_create_branch`
- `mcp__git__git_diff_unstaged`
- `mcp__git__git_checkout`
- `mcp__git__git_rm`
- `mcp__git__git_show`

**Alternative**: Use `git` commands via Bash tool instead.

## Why This Discrepancy Exists

Claude Code's internal tool approval list includes these MCP server functions as "approved" for future use, but they require the actual MCP servers to be:
1. Installed on the system
2. Configured in `mcp/mcp.json`
3. Running and accessible

Currently, only the Playwright MCP server meets all these requirements.

### Known Issue: Stale Cache

Claude Code may cache MCP server information, causing it to report servers as available even after they've been removed from `mcp/mcp.json`. This is automatically handled by `setup.sh` which clears the cache when updating MCP configuration.

If you manually edit `mcp/mcp.json`, you should:
1. Clear the cache: `rm -rf ~/.claude/statsig/*`
2. Restart your terminal session
3. Verify with: `claude mcp list`

## How to Add MCP Servers

To add additional MCP servers:

1. Install the server package:
   ```bash
   npm install -g @modelcontextprotocol/server-github
   # or
   npm install -g @modelcontextprotocol/server-git
   ```

2. Add configuration to `mcp/mcp.json`:
   ```json
   {
     "mcpServers": {
       "playwright": { /* existing config */ },
       "github": {
         "command": "mcp-server-github",
         "args": [],
         "env": {
           "GITHUB_TOKEN": "${GITHUB_TOKEN}"
         }
       }
     }
   }
   ```

3. Restart Claude Code to pick up the new configuration

## Checking Available MCP Servers

To verify which MCP servers are actually available:

1. Check the configuration:
   ```bash
   cat mcp/mcp.json
   ```

2. Ask Claude directly:
   ```
   What MCP servers do you have access to?
   ```

   **Note**: Claude should only report servers that are actually configured and running, not those merely in the approval list.

## Related Documentation

- [MCP Environment Setup](mcp-environment.md)
- [MCP Client Integration](mcp-client-integration.md)
- [Setting up all MCP servers](../mcp/setup-all-mcp-servers.sh)