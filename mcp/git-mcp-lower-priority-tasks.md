# Git MCP Server - Lower Priority Tasks Tracker

This file tracks the implementation status of lower priority git commands for the MCP server.

## Overview

These tasks are drawn from two GitHub issues:
- Issue #535: Useful but less critical git primitives (MEDIUM priority)
- Issue #536: Nice-to-have git primitives (LOW priority)

## Task List

### Medium Priority Tasks (Issue #535)

- [x] **git_reflog** - For recovery and history inspection
  - Status: COMPLETED
  - Description: Access git's reference log for recovery operations
  - Use case: Recover lost commits, understand branch history

- [x] **git_blame** - For line-by-line authorship
  - Status: COMPLETED
  - Description: Show who last modified each line of a file
  - Use case: Code archaeology, understanding code evolution

- [x] **git_revert** - For undoing commits
  - Status: COMPLETED
  - Description: Create a new commit that undoes a previous commit
  - Use case: Safe rollback of changes while preserving history

- [x] **git_reset_hard** - For hard resets
  - Status: COMPLETED
  - Description: Hard reset to a specific commit (destructive)
  - Note: We currently only have soft reset
  - Use case: Forcefully return to a previous state

- [x] **git_branch_delete** - For branch cleanup
  - Status: COMPLETED
  - Description: Delete local and remote branches
  - Use case: Repository maintenance and cleanup

- [x] **git_clean** - For removing untracked files
  - Status: COMPLETED
  - Description: Remove untracked files and directories
  - Use case: Clean working directory

### Low Priority Tasks (Issue #536)

- [ ] **git_bisect** - For binary search debugging
  - Status: TODO
  - Description: Binary search to find commit that introduced a bug
  - Note: Requires complex state management
  - Use case: Advanced debugging scenarios

- [ ] **git_describe** - For human-readable commit descriptions
  - Status: TODO
  - Description: Generate human-readable names for commits
  - Use case: Version tagging and release management

- [ ] **git_shortlog** - For contributor summaries
  - Status: TODO
  - Description: Summarize git log by contributor
  - Use case: Project statistics and contributor analysis

## Implementation Guidelines

All implementations should follow these patterns:

1. **Pydantic Models**: Define clear input/output models
2. **Error Handling**: Comprehensive error handling with meaningful messages
3. **Logging**: Integrate with existing logging_utils.py
4. **Documentation**: Clear tool descriptions with use cases
5. **Safety**: Add warnings/confirmations for destructive operations
6. **Integration**: Support git_batch for operation chaining

## Notes

- These tools enhance git workflow but aren't blocking daily operations
- Focus on safety for destructive operations (git_clean, git_reset_hard)
- Consider simplified interfaces for complex operations (especially git_bisect)
- All implementations should align with developer-experience principle

## References

- [Issue #535: Useful but less critical git primitives](https://github.com/atxtechbro/dotfiles/issues/535)
- [Issue #536: Nice-to-have git primitives](https://github.com/atxtechbro/dotfiles/issues/536)
- [MCP Git Server Implementation](../git-mcp-server/)