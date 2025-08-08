---
description: Create a new GitHub issue with intelligent labeling
argument-hint: [title] [description]
---

## Available Labels

- Labels: !`gh label list --repo atxtechbro/dotfiles --limit 10 --json name,description 2>/dev/null | jq -r '.[] | "  - \(.name): \(.description // "")"' || echo "Could not fetch labels"`

## Recent Issues

- Check duplicates: !`gh issue list --repo atxtechbro/dotfiles --limit 5 --json number,title,state 2>/dev/null | jq -r '.[] | "  #\(.number): \(.title) [\(.state)]"' || echo "Could not fetch recent issues"`

# Create Issue Command Template

{{ INJECT:procedures/issue-creation-procedure.md }}