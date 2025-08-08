# Close Issue Procedure
# 
# This IS the implementation - the procedure documents itself by being the code.
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
# Principle: systems-stewardship (single source of truth, documentation as code)

Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

{{ KNOWLEDGE_BASE }}
<!-- Note: If you see "{{ KNOWLEDGE_BASE }}" above as literal text, you're running locally and knowledge is already preloaded -->

## Workspace Ready
A git worktree has been pre-created at `../issue-{{ ISSUE_NUMBER }}` (or you're in the main repo if it failed).
The isolated environment is ready for implementation.

## Core Principle: Target-First Development
{{ INJECT:principles/tracer-bullets.md }}

## Analyze Issue #{{ ISSUE_NUMBER }}
The issue details and comments have been pre-loaded above.
Review the context to understand what needs to be implemented.

## Implement Solution
- Work in the current directory (main repo or worktree)
- Create commits with clear messages
- Reference "Closes #{{ ISSUE_NUMBER }}" in the PR body

## Final Step: Retro
Let's retro this context and wring out the gleanings.

{{ INJECT:principles/eager-evolution.md }}

**Consider capturing any ghost procedures** that emerged during this work - see [Procedure Creation](knowledge/procedures/procedure-creation.md).

**What would you like to focus on?**
- Do you have a specific aspect you want to double-click on?
- Or would you like me to suggest the top 3 areas I predict you'll find most valuable to explore?