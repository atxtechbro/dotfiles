# Manual Workflow Changes Required

## Context
Due to the GitHub workflows permission limitation documented in issue #1168, Claude cannot directly modify workflow files. The following changes need to be applied manually to complete the implementation.

## Required Change: Update Claude Implementation Workflow

**File**: `.github/workflows/claude-implementation.yml`

**Change**: Add documentation comment about the workflows permission limitation.

### Before (lines 1-14):
```yaml
# Claude Implementation Workflow
# THE SINGLE SOURCE OF TRUTH for @claude mentions in issues and PRs
# 
# This is the ONLY workflow that responds to @claude mentions.
# Uses the official anthropics/claude-code-action@beta to:
# - Implement issues when @claude is mentioned
# - Review PRs when @claude is mentioned
# - Create branches and push changes with proper permissions
#
# Note: Both claude[bot] and github-actions[bot] comments come from this workflow.
# The bot identity depends on the context and step being executed.
#
# Principle: subtraction-creates-value (removed duplicate workflow)
# Principle: systems-stewardship (single clear workflow to maintain)
```

### After (lines 1-17):
```yaml
# Claude Implementation Workflow
# THE SINGLE SOURCE OF TRUTH for @claude mentions in issues and PRs
# 
# This is the ONLY workflow that responds to @claude mentions.
# Uses the official anthropics/claude-code-action@beta to:
# - Implement issues when @claude is mentioned
# - Review PRs when @claude is mentioned
# - Create branches and push changes with proper permissions
#
# LIMITATION: Claude cannot modify workflow files (.github/workflows/) due to 
# missing 'workflows' permission on the GitHub App. See issue #1168 and
# /docs/github-workflows-permission-issue.md for details and workarounds.
#
# Note: Both claude[bot] and github-actions[bot] comments come from this workflow.
# The bot identity depends on the context and step being executed.
#
# Principle: subtraction-creates-value (removed duplicate workflow)
# Principle: systems-stewardship (single clear workflow to maintain)
```

## Instructions
1. Open `.github/workflows/claude-implementation.yml`
2. Add the three-line LIMITATION comment block after line 8
3. Save the file
4. Commit the change:
   ```bash
   git add .github/workflows/claude-implementation.yml
   git commit -m "Document workflows permission limitation in workflow file

   Adds comment explaining why Claude cannot modify workflow files.
   Relates to issue #1168 - GitHub workflows permission limitation.
   
   This change must be applied manually due to the exact limitation
   being documented."
   ```

## Why This Change is Important
- Documents the limitation directly in the affected workflow
- Provides clear reference to the issue and documentation
- Helps future maintainers understand why Claude can't modify this file
- Completes the comprehensive documentation of issue #1168

## Verification
After applying this change, the workflow will continue to function normally while clearly documenting its own limitation regarding workflow file modifications.

---
*This file can be deleted after the manual change is applied.*