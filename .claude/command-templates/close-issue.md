---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !`gh issue view $1`

## Workspace Setup

!`git worktree add "worktrees/$1-issue" -b "$1-issue"`
!`cd "worktrees/$1-issue"`

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}