---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !gh issue view $ARGUMENTS

## Workspace Setup

!git worktree add "worktrees/$ARGUMENTS-issue" -b "$ARGUMENTS-issue"
!cd "worktrees/$ARGUMENTS-issue"

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}