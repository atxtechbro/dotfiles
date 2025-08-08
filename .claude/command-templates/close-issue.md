---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !`gh issue view $1`

## Workspace Setup

- Create worktree: !`git worktree add "worktrees/$1-issue" -b "$1-issue" && echo "Worktree created at worktrees/$1-issue"`

# Close Issue Command Template

First, navigate to the worktree: `cd worktrees/{{ ISSUE_NUMBER }}-issue`

{{ INJECT:procedures/close-issue-procedure.md }}