# Close Issue Command Template
Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

## Core Principle: Target-First Development
{{ INJECT:principles/tracer-bullets.md }}

## Analyze Issue #{{ ISSUE_NUMBER }}
First, use `mcp__github__get_issue` to understand the issue and determine the appropriate workflow path.

{{ INJECT:procedures/close-issue-procedure.md }}

## Apply to Issue #{{ ISSUE_NUMBER }}
When following the procedure:
- Use issue #{{ ISSUE_NUMBER }} for all GitHub API calls
- Replace <NUMBER> with {{ ISSUE_NUMBER }} in branch names
- Replace <description> with issue title slug
- Reference "Closes #{{ ISSUE_NUMBER }}" in PR body

## Final Step: Retro
Let's retro this context and wring out the gleanings.

{{ INJECT:principles/eager-evolution.md }}

**Consider capturing any ghost procedures** that emerged during this work - see [Procedure Creation](knowledge/procedures/procedure-creation.md).

**What would you like to focus on?**
- Do you have a specific aspect you want to double-click on?
- Or would you like me to suggest the top 3 areas I predict you'll find most valuable to explore?