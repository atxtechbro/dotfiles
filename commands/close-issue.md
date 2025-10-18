---
description: Close GitHub issue with PR workflow
---

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
- Optional modifiers:
  - `--dry-run`: Preview execution plan without performing git operations (shows issue details, worktree location, commit preview, PR preview)
  - `--json`: Output in machine-readable JSON format (useful with --dry-run for tooling)
- Parsing rules:
  - Extract the first valid integer token after the command phrase as issue number
  - Detect flags anywhere in user input after command name
  - Natural language variants accepted: "dry run", "preview", "show me what would happen"
- Optional context: Any trailing text after the issue number should be treated as additional context (constraints, preferences, hints) and incorporated with graceful flexibility.

Examples:
- "close-issue 583" → Normal execution
- "close-issue 583 --dry-run" → Preview without execution
- "close-issue 583 --dry-run --json" → Machine-readable preview
- "close-issue 583 dry run" → Natural language variant
- "use the close-issue procedure to close GitHub issue 583"
- "please close issue #583"

Provider Notes:
- Prefer absolute file paths when possible
- Use Git worktrees for isolation (see Worktree Workflow)

Complete and implement GitHub issue #{{ ISSUE_NUMBER }}.

{{ KNOWLEDGE_BASE }}
<!-- Note: If you see "{{ KNOWLEDGE_BASE }}" above as literal text, you're running locally and knowledge is already preloaded -->

## Step 0: Parse Execution Modifiers

Detect dry-run and JSON output flags from user input:

!# Parse flags from the user's command invocation
!# Supports --dry-run, --json, and natural language variants
!DRY_RUN=false
!JSON_OUTPUT=false
!
!# Get the full user input (this variable is provided by the LLM context)
!USER_INPUT="${USER_INPUT:-$*}"
!
!# Check for dry-run flag variants
!if echo "$USER_INPUT" | grep -qiE '(--dry-run|dry\.run|preview|show\.me\.what\.would\.happen)'; then
!  DRY_RUN=true
!fi
!
!# Check for JSON output flag
!if echo "$USER_INPUT" | grep -qiE '(--json)'; then
!  JSON_OUTPUT=true
!fi
!
!# If dry-run mode detected, show banner
!if [ "$DRY_RUN" = "true" ]; then
!  if [ "$JSON_OUTPUT" = "true" ]; then
!    echo '{"dry_run": true, "mode": "json", "command": "close-issue"}'
!  else
!    echo "🧠 Dry Run Mode: Close Issue"
!    echo "──────────────────────────────────────"
!    echo "Preview mode - no git operations will be performed"
!    echo ""
!  fi
!fi

The dry-run mode will:
- Fetch and display issue details (read-only)
- Show planned worktree location and branch name
- Preview commit message and PR details
- Display all git commands that would be executed
- Exit before any destructive operations
- Output either human-readable format (default) or JSON (with --json flag)

## Step 1: Fetch Issue Details

Fetch issue context from GitHub (safe read-only operation, runs in both normal and dry-run modes):

!ISSUE_NUMBER="{{ ISSUE_NUMBER }}"
!ISSUE_NUMBER="{{ ISSUE_NUMBER }}"
!if ! ISSUE_DATA=$(gh issue view "$ISSUE_NUMBER" --json title,body,labels,number 2>/dev/null); then
!  echo "Error: Could not fetch issue #$ISSUE_NUMBER. Please check:"
!  echo "  - Issue number is correct"
!  echo "  - You have access to the repository"
!  echo "  - GitHub CLI is authenticated (run 'gh auth status')"
!  exit 1
!fi
!ISSUE_TITLE=$(echo "$ISSUE_DATA" | jq -r '.title')
!ISSUE_BODY=$(echo "$ISSUE_DATA" | jq -r '.body')
!
!echo "Fetched issue #$ISSUE_NUMBER: $ISSUE_TITLE"

## Step 2: Dry-Run Preview (If Enabled)

If dry-run mode is active, show the execution plan and exit:

!if [ "$DRY_RUN" = "true" ]; then
!  # Calculate planned values
!  ISSUE_SLUG=$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | cut -c1-50)
!  BRANCH_NAME="issue-${ISSUE_NUMBER}-${ISSUE_SLUG}"
!  WORKTREE_PATH="${HOME}/worktrees/issue-${ISSUE_NUMBER}"
!
!  if [ "$JSON_OUTPUT" = "true" ]; then
!    # JSON format output
!    cat <<EOF
!{
!  "dry_run": true,
!  "command": "close-issue",
!  "issue": {
!    "number": $ISSUE_NUMBER,
!    "title": "$ISSUE_TITLE",
!    "repository": "atxtechbro/dotfiles"
!  },
!  "planned_actions": [
!    {"step": 1, "description": "Fetch issue details", "status": "completed (read-only)"},
!    {"step": 2, "description": "Create worktree", "path": "$WORKTREE_PATH", "branch": "$BRANCH_NAME"},
!    {"step": 3, "description": "Implement solution", "note": "Interactive with user"},
!    {"step": 4, "description": "Create commit", "message": "Closes #$ISSUE_NUMBER"},
!    {"step": 5, "description": "Push branch to origin"},
!    {"step": 6, "description": "Create pull request"}
!  ],
!  "would_execute": [
!    "git worktree add $WORKTREE_PATH -b $BRANCH_NAME",
!    "git commit -m 'feat: <implementation>\\n\\nCloses #$ISSUE_NUMBER'",
!    "git push -u origin $BRANCH_NAME",
!    "gh pr create --title '<PR title>' --body '...'"
!  ],
!  "execution_status": "skipped (dry-run mode)"
!}
!EOF
!  else
!    # Human-readable format
!    echo ""
!    echo "Issue #$ISSUE_NUMBER: $ISSUE_TITLE"
!    echo "──────────────────────────────────────"
!    echo "Repository: atxtechbro/dotfiles"
!    echo "Base Branch: main"
!    echo ""
!    echo "Planned Actions:"
!    echo "  1. ✓ Fetch issue details (completed - read-only)"
!    echo "  2. Create worktree at: $WORKTREE_PATH"
!    echo "  3. Create branch: $BRANCH_NAME"
!    echo "  4. Implement solution (interactive with you)"
!    echo "  5. Commit changes with message: 'Closes #$ISSUE_NUMBER'"
!    echo "  6. Push branch to origin"
!    echo "  7. Create PR with title from implementation"
!    echo ""
!    echo "Would Execute Commands:"
!    echo "  \$ gh issue view $ISSUE_NUMBER --json title,body,labels"
!    echo "  \$ git worktree add $WORKTREE_PATH -b $BRANCH_NAME"
!    echo "  \$ cd $WORKTREE_PATH"
!    echo "  \$ # [Interactive implementation happens here]"
!    echo "  \$ git add ."
!    echo "  \$ git commit -m 'feat: <description>\\n\\nCloses #$ISSUE_NUMBER'"
!    echo "  \$ git push -u origin $BRANCH_NAME"
!    echo "  \$ gh pr create --title '<title>' --body '<body>'"
!    echo ""
!    echo "──────────────────────────────────────"
!    echo "(No git operations executed - dry-run mode)"
!    echo ""
!    echo "To execute for real, run without --dry-run flag"
!  fi
!  exit 0
!fi

## Implementation
<!-- Contract: Issue context loaded, working in worktree -->
Build the solution using tracer bullets - get something working first, then iterate.

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

**Consider capturing any ghost procedures** that emerged during this work - see [Procedure Creation](knowledge/procedures/procedure-creation.md).

**What would you like to focus on?**
- Do you have a specific aspect you want to double-click on?
- Or would you like me to suggest the top 3 areas I predict you'll find most valuable to explore?
