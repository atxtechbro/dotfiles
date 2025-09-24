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

When implementation is complete, create a PR that follows the template structure and references "Closes #{{ ISSUE_NUMBER }}".

**IMPORTANT**: This procedure outputs a GitHub Pull Request. The PR must be created, not just planned.

Use this exact command structure with heredoc to ensure proper markdown formatting:

```bash
# Generate PR title following recruiter-optimization pattern
# Pattern: type: [action verb] [quantified impact] [technology keywords]
PR_TITLE="fix: enforce PR template structure in automated workflows for consistency"

# Create PR with properly formatted body using heredoc
gh pr create --title "$PR_TITLE" --body "$(cat <<'EOF'
## Summary
- Enforces consistent PR template usage across all automated workflows
- Eliminates markdown formatting issues from escaped newlines
- Ensures both GitHub Actions and local commands follow the same structure

## What Changed
- Updated close-issue procedure with explicit PR creation command
- Modified GitHub Actions workflow to use inline template structure
- Added heredoc examples to prevent formatting issues

## Why
Closes #{{ ISSUE_NUMBER }}

Automated PR creation was drifting from the template guidance, causing:
- Inconsistent structure between manual and automated PRs
- Escaped newlines breaking markdown rendering
- Missing standard sections that reviewers expect
- Poor readability and context for technical reviews

## References
- PR Template: .github/PULL_REQUEST_TEMPLATE.md
- Issue: #{{ ISSUE_NUMBER }}

## Git Statistics
\`\`\`
$(git diff --stat main...HEAD)
\`\`\`
EOF
)"
```

This ensures:
1. ✅ Recruiter-optimized title with AI/ML keywords
2. ✅ All template sections included (Summary, What Changed, Why, References, Stats)
3. ✅ Proper markdown formatting (no escaped newlines)
4. ✅ Clear connection to the issue being closed

## Final Step: Retro
Let's retro this context and wring out the gleanings.

{{ INJECT:principles/eager-evolution.md }}

**Consider capturing any ghost procedures** that emerged during this work - see [Procedure Creation](knowledge/procedures/procedure-creation.md).

**What would you like to focus on?**
- Do you have a specific aspect you want to double-click on?
- Or would you like me to suggest the top 3 areas I predict you'll find most valuable to explore?
