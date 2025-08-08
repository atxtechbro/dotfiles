---
description: Complete and implement a GitHub issue
argument-hint: <issue-number>
---

## Issue Context

- Issue details: !`gh issue view $1 --repo atxtechbro/dotfiles --json number,title,state,labels 2>/dev/null | jq -r '"#\(.number): \(.title)\nState: \(.state)\nLabels: \(.labels | map(.name) | join(", "))"' || echo "Issue #$1 not found"`
- Comments: !`gh issue view $1 --repo atxtechbro/dotfiles --json comments 2>/dev/null | jq -r '.comments[:3][] | "[\(.author.login)]: \(.body | split("\n")[0])"' || echo "No comments"`
- Related commits: !`git log --oneline -5 --grep="#$1" 2>/dev/null || echo "No commits referencing #$1"`

## Workspace Setup

- Create worktree: !`BRANCH="issue-$1-$(gh issue view $1 --json title 2>/dev/null | jq -r .title | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | cut -c1-30)" && git worktree add "../dotfiles-$BRANCH" -b "$BRANCH" 2>&1 | grep -v "fatal" || echo "Using current directory"`

# Close Issue Command Template

{{ INJECT:procedures/close-issue-procedure.md }}