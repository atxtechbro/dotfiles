# Close Issue Procedure
#
# IMPORTANT: This procedure creates a Pull Request that will auto-close the issue when merged.
# It does NOT directly close the issue - GitHub closes it automatically via PR merge.
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

## Invocation (Provider-Agnostic)
- Primary command: "close-issue <number>"
- Alternative formats: "close issue <number>" (without hyphen)
- Arguments:
  - <number>: GitHub issue number
- Optional context: Any trailing text after the issue number should be treated as additional context (constraints, preferences, hints) and incorporated with graceful flexibility.
- Parsing rule: Extract the first valid integer token after the command phrase; if no integer is found or multiple integers appear without clear context, prompt the user to clarify the issue number.

Examples:
- "close-issue 583"
- "use the close-issue procedure to close GitHub issue 583"
- "please close issue #583"

Provider Notes:
- Prefer absolute file paths when possible
- Use Git worktrees for isolation (see Worktree Workflow)

Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

{{ KNOWLEDGE_BASE }}
<!-- Note: If you see "{{ KNOWLEDGE_BASE }}" above as literal text, you're running locally and knowledge is already preloaded -->

## Implementation
<!-- Contract: Issue context loaded, working in worktree -->
Build the solution using tracer bullets - get something working first, then iterate.

{{ INJECT:principles/tracer-bullets.md }}

## Creating the Pull Request

**IMPORTANT**: This procedure outputs a GitHub Pull Request. The PR must be created, not just planned.

**KEY WORKFLOW**:
- Create commits with "Closes #issue-number" in the message
- Create the Pull Request linking to the issue
- The issue will be automatically closed when the PR is merged
- Do NOT manually close the issue yourself

See `.github/PULL_REQUEST_TEMPLATE.md` for complete guidance on title patterns and body sections.

## Final Step: Retro
Let's retro this context and wring out the gleanings.

{{ INJECT:principles/eager-evolution.md }}

**Consider capturing any ghost procedures** that emerged during this work - see [Procedure Creation](knowledge/procedures/procedure-creation.md).

**What would you like to focus on?**
- Do you have a specific aspect you want to double-click on?
- Or would you like me to suggest the top 3 areas I predict you'll find most valuable to explore?
