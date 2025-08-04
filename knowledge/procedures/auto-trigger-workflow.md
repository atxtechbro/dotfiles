# Auto-Trigger Workflow

Enables Ultimate OSE automation where GitHub issues automatically trigger Claude to implement and create PRs with zero manual intervention.

## How It Works

1. Issue created on GitHub
2. `.github/workflows/auto-trigger-claude.yml` fires automatically
3. Claude receives explicit MCP instructions to CREATE PR (not just link)
4. Claude implements and creates PR using `mcp__github__create_pull_request`

## Key Difference from /close-issue

- **Auto-trigger**: Fully automated, runs in GitHub Actions
- **/close-issue**: Local command, requires manual trigger

## The Secret Sauce

The explicit instruction that makes it work:

- Must say "CREATE the pull request automatically"
- Must specify "using mcp__github__create_pull_request"
- Must say "Do NOT just provide a link"

## Implementation Details

### Workflow Trigger
The workflow triggers on `issues.opened` events and immediately posts a comment with specific instructions:

```markdown
@claude Please implement this issue and CREATE the pull request automatically.

Remember:
- CREATE the PR automatically using mcp__github__create_pull_request (not gh cli)
- Do NOT just provide a link - actually create the PR
- Do NOT approve the PR (only humans approve)

This is OSE automation - the PR must be created automatically.
```

### Why It Works
The key is the explicit MCP tool instruction (`mcp__github__create_pull_request`) which ensures Claude uses the GitHub MCP server instead of trying to generate manual PR links.

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