# Auto-Trigger Workflow

Enables hybrid OSE automation where GitHub issues can trigger Claude implementation via label or manual mention.

## How It Works

### Method 1: Label-Based Auto-Trigger (Opt-In)
1. Create or open an issue on GitHub
2. Add the `claude` label to the issue
3. `.github/workflows/auto-trigger-claude.yml` fires automatically
4. Claude receives instruction to implement the issue
5. The `anthropics/claude-code-action` automatically creates the PR after Claude completes the implementation

### Method 2: Manual @claude Mention
1. Create or open an issue on GitHub
2. Comment `@claude` in the issue (with optional context)
3. `.github/workflows/claude-implementation.yml` fires on the mention
4. Claude receives instruction to implement the issue
5. The `anthropics/claude-code-action` automatically creates the PR after Claude completes the implementation

## Key Difference from /close-issue

- **Auto-trigger**: Fully automated, runs in GitHub Actions
- **/close-issue**: Local command, requires manual trigger

## The Secret Sauce

The `anthropics/claude-code-action@beta` GitHub Action handles PR creation automatically:

- Claude focuses on implementation
- The Action creates branches with `claude/` prefix
- The Action automatically creates the PR when work is complete
- No manual PR creation tools needed

## Implementation Details

### Label-Based Workflow Trigger
The auto-trigger workflow activates on `issues.labeled` events when:
- The `claude` label is added to an issue
- Repository variable `CLAUDE_CODE_SUBSCRIPTION` is set to `active`

It posts this comment to trigger implementation:

```markdown
@claude Please implement this issue and CREATE AN ACTUAL PULL REQUEST on GitHub.

**IMPORTANT**: You MUST create a real PR on GitHub (not just provide a link to create one). use branch name according to repo guidelines such that branch name contains issue number suffix and is guaranteed to be unique. The PR must be created and visible at github.com/atxtechbro/dotfiles/pulls.

**NOTE**: You now have access to the full knowledge base including all principles (tracer-bullets, versioning-mindset, OSE, etc.) and procedures (git-workflow, worktree-workflow, etc.). Use this context to create high-quality PRs that follow established patterns.

Use the PR template from https://github.com/atxtechbro/dotfiles/blob/main/.github/PULL_REQUEST_TEMPLATE.md when creating the pull request.
```

### Manual Mention Workflow Trigger
The implementation workflow activates on any `@claude` mention in:
- Issue comments
- Pull request comments
- Pull request review comments

No label required - just mention `@claude` with optional context.

### Why It Works
The `anthropics/claude-code-action` has built-in PR creation capability. After Claude pushes changes to a branch, the Action automatically creates a PR without Claude needing to call any PR creation tools. This is simpler and more reliable than manual tool invocation.

## When to Use

### Use Label-Based Auto-Trigger When:
- Issue requires implementation work
- Want to batch-queue multiple issues for automation
- Want visual indicator of which issues are queued
- Following Ultimate OSE principles with opt-in control
- Need audit trail of automated work

### Use Manual @claude Mention When:
- Want to trigger implementation on-demand
- Need to provide specific context or constraints
- Issue doesn't need the `claude` label permanently
- Quick ad-hoc implementation request

### Use /close-issue When:
- Working locally with Claude Code
- Need interactive discussion during implementation
- Prefer manual control over PR creation
- Issue is complex and needs human oversight
- Testing changes locally before pushing

## Related Files

- Workflow: `.github/workflows/auto-trigger-claude.yml`
- Implementation: `.github/workflows/claude-implementation.yml`
- Local procedure: `knowledge/procedures/close-issue-procedure.md`

## Usage Examples

### Label-Based Triggering
```bash
# Add claude label to an issue to queue for auto-implementation
gh issue edit 123 --add-label "claude"

# Batch-add label to multiple issues
gh issue list --state open --json number --jq '.[].number' | \
  xargs -I {} gh issue edit {} --add-label "claude"

# Remove label to prevent auto-trigger
gh issue edit 123 --remove-label "claude"
```

### Manual @claude Mention
```markdown
# In issue comment:
@claude Please implement this with focus on performance optimization

# In PR review:
@claude Can you review this approach and suggest improvements?
```

## Principles Applied

- **systems-stewardship**: Document systems for future maintainers
- **ose**: Automated workflows with intentional opt-in control
- **snowball-method**: Knowledge persistence for compound improvement
- **subtraction-creates-value**: Removed overly-eager auto-trigger, added intentional control