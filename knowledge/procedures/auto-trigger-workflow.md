# Auto-Trigger Workflow

Enables Ultimate OSE automation where GitHub issues automatically trigger Claude to implement and create PRs with zero manual intervention.

## How It Works

1. Issue created on GitHub
2. `.github/workflows/auto-trigger-claude.yml` fires automatically
3. Claude receives instructions to implement the issue
4. The `anthropics/claude-code-action@beta` automatically creates the PR after Claude completes implementation

## Key Difference from /close-issue

- **Auto-trigger**: Fully automated, runs in GitHub Actions
- **/close-issue**: Local command, requires manual trigger

## The Secret Sauce

The GitHub Action handles PR creation automatically:

- Claude focuses on implementing the solution
- The `anthropics/claude-code-action@beta` creates the PR after implementation
- No need for explicit PR creation instructions to Claude

## Implementation Details

### Workflow Trigger
The workflow triggers on `issues.opened` events and immediately posts a comment with simple instructions:

```markdown
@claude Please implement this issue. The pull request will be created automatically after you complete the implementation.

Remember:
- Do NOT approve the PR (only humans approve)

This is OSE automation - focus on implementing the solution and the GitHub Action will handle PR creation.
```

### Why It Works
The `anthropics/claude-code-action@beta` GitHub Action automatically creates PRs after Claude completes implementation work. Claude doesn't need to explicitly create PRs - it just needs to implement the solution.

## When to Use

### Use Auto-Trigger When:
- Issue requires implementation work
- Want zero manual intervention 
- Following Ultimate OSE principles
- Need audit trail of automated work

### Use /close-issue When:
- Working locally with Claude Code
- Need interactive discussion during implementation
- Prefer manual control over PR creation
- Issue is complex and needs human oversight

## Related Files

- Workflow: `.github/workflows/auto-trigger-claude.yml`
- Implementation: `.github/workflows/claude-implementation.yml`
- Local procedure: `knowledge/procedures/close-issue-procedure.md`

## Principles Applied

- **systems-stewardship**: Document systems for future maintainers
- **ose**: Ultimate automation with zero manual intervention
- **snowball-method**: Knowledge persistence for compound improvement