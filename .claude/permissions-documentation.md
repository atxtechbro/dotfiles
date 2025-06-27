# Claude Code Permission Auto-Approval Documentation

## Overview
This document explains the permission changes made to enable hands-off keyboard operation in Claude Code by auto-approving trivial read-only operations.

## Changes Made
Added the following tools to the auto-approve allow list in `.claude/settings.local.json`:

### Core Read-Only Tools
- **Read** - File reading operations
- **LS** - Directory listing operations  
- **Glob** - File pattern matching
- **Grep** - Content searching
- **Task** - Search agent operations
- **TodoRead** - Reading todo lists
- **NotebookRead** - Reading Jupyter notebooks
- **WebSearch** - Web searching
- **ListMcpResourcesTool** - Listing MCP resources
- **ReadMcpResourceTool** - Reading MCP resources

### MCP Filesystem Read Operations
- **mcp__filesystem__list_files** - List files in directory
- **mcp__filesystem__list_all_files** - List all files recursively
- **mcp__filesystem__file_tree** - Display file tree structure
- **mcp__filesystem__file_info** - Get file metadata
- **mcp__filesystem__search_files** - Search for files

## Rationale
These are all read-only operations that:
1. Cannot modify or delete data
2. Are frequently used during normal development
3. Were causing constant permission prompts
4. Block the goal of hands-off keyboard operation

## Security Considerations
- Only read operations are auto-approved
- Write, delete, and execute operations still require explicit approval
- Sensitive operations like AWS access remain protected
- Project-specific permissions can override these defaults

## Testing
To verify these permissions work:
1. Restart Claude Code
2. Try operations like listing files, reading files, searching
3. Confirm no permission prompts appear for these operations
4. Verify write operations still prompt for permission

Principle: selective-optimization