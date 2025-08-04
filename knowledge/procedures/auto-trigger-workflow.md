# Auto-Trigger Workflow

Enables Ultimate OSE automation where GitHub issues automatically trigger Claude to implement and create PRs with zero manual intervention.

## How It Works

1. Issue created on GitHub
2. `.github/workflows/auto-trigger-claude.yml` fires automatically
3. Claude receives instruction to implement the issue
4. The `anthropics/claude-code-action` automatically creates the PR after Claude completes the implementation

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

### Workflow Trigger
The workflow triggers on `issues.opened` events and posts a simple comment:

```markdown
@claude Please implement this issue. The pull request will be created automatically after you complete the implementation.
```

### Why It Works
The `anthropics/claude-code-action` has built-in PR creation capability. After Claude pushes changes to a branch, the Action automatically creates a PR without Claude needing to call any PR creation tools. This is simpler and more reliable than manual tool invocation.

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