# Git MCP Command Chaining and Logging Behavior

This document explains how the [MCP tool-level logging framework](../mcp/README.md#adding-tool-level-logging-to-mcp-servers) handles chained git commands.

## How Logging Works with git_batch

When you use `git_batch`, it creates **ONE log entry** for the entire batch operation:
- Tool name: `git_batch`
- Details: "Batch executed: X/Y succeeded"
- Individual commands within the batch are NOT logged separately
- The formatted results show success/failure for each command in the response

## Why This Design?

1. **Cleaner Logs**: Avoids cluttering logs with implementation details
2. **Atomic Operations**: Treats chained operations as single logical units
3. **Better Analytics**: Easier to track usage patterns of workflows vs individual commands
4. **Performance**: Reduces log write operations

## Example Usage

```python
mcp__git__git_batch(
  repo_path="/path/to/repo",
  commands=[
    {"tool": "git_add", "args": {"files": ["*.py"]}},
    {"tool": "git_commit", "args": {"message": "feat: add feature"}},
    {"tool": "git_push", "args": {"set_upstream": true}}
  ]
)
```

## Example Log Output

Instead of three separate log entries:
```
git_add | STATUS: SUCCESS | Added files: ["file.py"]
git_commit | STATUS: SUCCESS | Committed: abc123
git_push | STATUS: SUCCESS | Pushed main to origin
```

You get one consolidated entry:
```
git_batch | STATUS: SUCCESS | Batch executed: 3/3 succeeded
```

This design follows the principle of abstraction - log at the level of user intent, not implementation details.

## Log Location

All tool calls are logged to `~/mcp-tool-calls.log` as configured in the [logging framework](../mcp/README.md#tool-level-logging-guidelines). Use `check-mcp-logs -t` to view recent tool calls.