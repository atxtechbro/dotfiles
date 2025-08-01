# Tool Discovery Guide

Semantic mapping of common tasks to the right tools. When you're unsure which tool to use, start here.

## Task-to-Tool Mapping

### File Operations

**"I need to find files by name or pattern"**
→ Use `Glob` with patterns like `**/*.js` or `src/**/*.ts`

**"I need to search for text inside files"**
→ Use `Grep` for content search (supports regex, file filtering, context lines)

**"I need to read a file"**
→ Use `Read` for viewing file contents

**"I need to edit a file"**
→ Use `Edit` for single changes, `MultiEdit` for multiple changes in same file

**"I need to create a new file"**
→ Use `Write` (but always prefer editing existing files)

**"I need to explore a directory structure"**
→ Use `LS` to list files and directories

### Git Operations

**"I need to check git status"**
→ Use `mcp__git__git_status`

**"I need to create a new branch"**
→ Use `mcp__git__git_create_branch` or `mcp__git__git_worktree_add`

**"I need to commit changes"**
→ Use `mcp__git__git_add` then `mcp__git__git_commit`

**"I need to see what changed"**
→ Use `mcp__git__git_diff` (staged) or `mcp__git__git_diff_unstaged`

**"I need to work on multiple issues simultaneously"**
→ Use `mcp__git__git_worktree_add` for complete isolation

### GitHub Operations

**"I need to create a pull request"**
→ Use `mcp__github__create_pull_request`

**"I need to work with issues"**
→ Use `mcp__github__list_issues`, `mcp__github__get_issue`, `mcp__github__create_issue`

**"I need to search GitHub"**
→ Use `mcp__github__search_code`, `mcp__github__search_repositories`

**"I need to review PRs"**
→ Use `mcp__github__get_pull_request`, `mcp__github__get_pull_request_diff`

### Web and Browser Tasks

**"I need to browse a website"**
→ Use `mcp__playwright__browser_navigate` and related browser tools

**"I need to search the web"**
→ Use `WebSearch` (built into Claude Code) or `mcp__brave-search__brave_web_search`

**"I need to fetch content from a URL"**
→ Use `WebFetch` for simple content retrieval

### Complex Tasks

**"I need to search across many files with complex logic"**
→ Use `Task` with subagent_type: "general-purpose"

**"I need to run shell commands"**
→ Use `Bash` (but prefer MCP tools when available)

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