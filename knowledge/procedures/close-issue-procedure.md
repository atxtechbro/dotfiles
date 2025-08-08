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

## Implementation
<!-- Contract: Issue context loaded, working in worktree -->
Build the solution using tracer bullets - get something working first, then iterate.

{{ INJECT:principles/tracer-bullets.md }}

When complete, create a PR that references "Closes #{{ ISSUE_NUMBER }}".

## Final Step: Retro
Let's retro this context and wring out the gleanings.

{{ INJECT:principles/eager-evolution.md }}

**Consider capturing any ghost procedures** that emerged during this work - see [Procedure Creation](knowledge/procedures/procedure-creation.md).

**What would you like to focus on?**
- Do you have a specific aspect you want to double-click on?
- Or would you like me to suggest the top 3 areas I predict you'll find most valuable to explore?