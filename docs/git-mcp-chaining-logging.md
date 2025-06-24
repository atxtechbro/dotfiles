# Git MCP Command Chaining and Logging Behavior

## How Logging Works with Chained Commands

### git_stage_commit_push
When you use `git_stage_commit_push`, it creates **ONE log entry** for the entire operation:
- Tool name: `git_stage_commit_push`
- Details: "Stage-commit-push completed"
- The individual add/commit/push operations are NOT logged separately
- This provides a cleaner log focused on the high-level operation

### git_batch
When you use `git_batch`, it also creates **ONE log entry** for the batch:
- Tool name: `git_batch`
- Details: "Batch executed: X/Y succeeded"
- Individual commands within the batch are NOT logged separately
- The formatted results show success/failure for each command in the response

## Why This Design?

1. **Cleaner Logs**: Avoids cluttering logs with implementation details
2. **Atomic Operations**: Treats chained operations as single logical units
3. **Better Analytics**: Easier to track usage patterns of workflows vs individual commands
4. **Performance**: Reduces log write operations

## Example Log Output

Instead of:
```
git_add | STATUS: SUCCESS | Added files: ["file.py"]
git_commit | STATUS: SUCCESS | Committed: abc123
git_push | STATUS: SUCCESS | Pushed main to origin
```

You get:
```
git_stage_commit_push | STATUS: SUCCESS | Stage-commit-push completed
```

This design follows the principle of abstraction - log at the level of user intent, not implementation details.