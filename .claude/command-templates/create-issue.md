---
description: Create a new GitHub issue with intelligent labeling
argument-hint: [title] [description]
---

## Available Labels

- Labels: !`gh label list --limit 10 --json name,description | jq -r '.[] | "  - \(.name): \(.description // "")"'`

## Recent Issues

- Check duplicates: !`gh issue list --limit 5 --json number,title,state | jq -r '.[] | "  #\(.number): \(.title) [\(.state)]"'`

# Create Issue Command Template

{{ INJECT:procedures/issue-creation-procedure.md }}