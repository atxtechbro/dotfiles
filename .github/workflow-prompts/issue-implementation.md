# Issue Implementation Template
# 
# This is the SINGLE SOURCE OF TRUTH for issue implementation.
# Used by both:
# - Local /close-issue command (via relative path injection)
# - GitHub Actions @claude workflow (with knowledge base injection)
#
# IMPORTANT: How {{ KNOWLEDGE_BASE }} works:
# - For GitHub Actions: Gets replaced with aggregated knowledge files via string substitution
# - For local /close-issue: Remains as literal text "{{ KNOWLEDGE_BASE }}" in the prompt
#   (harmless since knowledge is already preloaded in Claude's context)
# 
# This is NOT smart placeholder logic - it's simple:
# - GitHub Actions: Does string replacement: {{ KNOWLEDGE_BASE }} → actual content
# - Local command: Does NO replacement: {{ KNOWLEDGE_BASE }} → stays as literal text
#
# Principle: systems-stewardship (single source of truth)

Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

{{ KNOWLEDGE_BASE }}
<!-- Note: If you see "{{ KNOWLEDGE_BASE }}" above as literal text, you're running locally and knowledge is already preloaded -->

## Core Principle: Target-First Development
{{ INJECT:principles/tracer-bullets.md }}

## Analyze Issue #{{ ISSUE_NUMBER }}
<!-- This template IS the procedure - executable documentation -->
First, use `mcp__github__get_issue` to understand the issue and determine the appropriate workflow path.

<!-- The injected procedure below provides decision matrices and workflow paths -->
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