# Git MCP Server Test Guide

This document provides instructions for testing the Git MCP server integration.

## Prerequisites

1. The Git MCP server has been set up using `setup-git-mcp.sh`
2. Amazon Q or another MCP client is configured to use the server

## Test Cases

### Basic Git Operations

1. **Check Git Status**
   ```
   Check the status of the current Git repository
   ```
   Expected: The status of the Git repository should be displayed correctly.

2. **List Branches**
   ```
   List all branches in the current Git repository
   ```
   Expected: A list of branches in the repository.

3. **View Commit History**
   ```
   Show the commit history of the current Git repository
   ```
   Expected: A list of recent commits with their details.

### Advanced Git Operations

1. **Create a Branch**
   ```
   Create a new Git branch named "test-branch"
   ```
   Expected: The branch should be created successfully.

2. **Switch Branches**
   ```
   Switch to the "test-branch" branch
   ```
   Expected: The current branch should be changed to "test-branch".

3. **Make Changes and Commit**
   ```
   Create a test file, add it to Git, and commit it
   ```
   Expected: The file should be created, added, and committed successfully.

### Git Worktree Operations

1. **List Worktrees**
   ```
   List all Git worktrees in the current repository
   ```
   Expected: A list of worktrees in the repository.

2. **Add a Worktree**
   ```
   Add a new Git worktree at "/tmp/test-worktree" using the "test-branch" branch
   ```
   Expected: A new worktree should be created at the specified path.

3. **Move a Worktree**
   ```
   Move the Git worktree from "/tmp/test-worktree" to "/tmp/test-worktree-new"
   ```
   Expected: The worktree should be moved to the new location.

4. **Remove a Worktree**
   ```
   Remove the Git worktree at "/tmp/test-worktree-new"
   ```
   Expected: The worktree should be removed.

5. **Prune Worktrees**
   ```
   Prune all stale Git worktrees in the current repository
   ```
   Expected: Any stale worktrees should be pruned.

## Cleanup

After testing, clean up the test branch and worktrees:

```
Delete the "test-branch" branch
Remove any remaining test worktrees
```

## Troubleshooting

If you encounter issues:

1. Check that the built version exists at `mcp/servers/git-mcp-server/dist/index.js`
2. Verify that the wrapper script is using the built version
3. Check for error messages in the MCP client output
4. Try rebuilding the server using `setup-git-mcp.sh`

## Reporting Issues

If you find bugs or have suggestions for improvements, please create an issue in the repository with:

1. A clear description of the problem
2. Steps to reproduce the issue
3. Expected vs. actual behavior
4. Any error messages or logs

## Future Enhancements

The following features are planned for future implementation:

1. **Custom Git Hooks Integration**: Improved support for Git hooks
2. **Performance Optimizations**: Reducing response time for large repositories
