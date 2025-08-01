# Tool Discovery Guide

Guidelines for effective tool selection in this repository.

## Tool Selection Principles

1. **Prefer MCP tools over Bash commands**
   - Instead of `git status` → use `mcp__git__git_status`
   - Instead of `grep` → use `Grep` tool
   - Instead of `find` → use `Glob` tool

2. **Use the most specific tool available**
   - For GitHub operations → use mcp__github__ tools
   - For git operations → use mcp__git__ tools
   - For file operations → use built-in file tools

3. **Batch operations when possible**
   - Use `MultiEdit` for multiple edits in one file
   - Use `mcp__git__git_batch` for multiple git operations
   - Call multiple tools in parallel when gathering information

4. **Consider context windows**
   - Use `Task` for open-ended searches that might require multiple attempts
   - Use direct tools when you know exactly what you're looking for
   - Use `limit` parameters on Read to manage large files

## Common Patterns

### Starting a New Feature
1. `mcp__git__git_status` - Check current state
2. `mcp__git__git_fetch` - Sync with remote
3. `mcp__git__git_create_branch` or `mcp__git__git_worktree_add`
4. Work on feature using appropriate tools
5. `mcp__git__git_add` + `mcp__git__git_commit`
6. `mcp__git__git_push`
7. `mcp__github__create_pull_request`

### Investigating an Issue
1. `mcp__github__get_issue` - Get issue details
2. `Grep` or `Glob` - Find relevant files
3. `Read` - Examine code
4. `Edit` or `MultiEdit` - Make changes
5. Follow git workflow above

### Debugging MCP Servers
1. `Read` mcp/README.md for debugging steps
2. `Bash` check-mcp-health.sh
3. `Read` relevant wrapper scripts
4. `mcp__git__git_status` to check for uncommitted changes

## Quick Reference

| Need to... | Use... |
|------------|--------|
| Find files | `Glob` |
| Search in files | `Grep` |
| Read files | `Read` |
| Edit files | `Edit` / `MultiEdit` |
| Create files | `Write` |
| List directories | `LS` |
| Run commands | `Bash` |
| Complex search | `Task` |
| Git operations | `mcp__git__*` |
| GitHub operations | `mcp__github__*` |
| Browse web | `mcp__playwright__*` |
| Search web | `WebSearch` |

Remember: When in doubt, check [AI Index](../knowledge/ai-index.md) for guidance.