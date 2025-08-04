# Auto-Trigger Workflow

Automatically dispatches Claude to implement issues upon creation - the Ultimate OSE achievement.

## How It Works

1. **Issue Created**: Any new issue triggers the workflow
2. **Auto-Comment**: PAT-authenticated comment "@claude Please implement..."
3. **Claude Triggered**: claude-implementation.yml responds to the mention
4. **Implementation Begins**: Claude creates branch, implements, creates PR
5. **Zero Manual Steps**: Complete automation from issue to PR

## Configuration

Located in `.github/workflows/auto-trigger-claude.yml`:
- Triggers on: `issues: [opened]`
- Uses: `CLAUDE_TRIGGER_PAT` secret (not GITHUB_TOKEN)
- No conditions - triggers on EVERY issue

## Why PAT Instead of GITHUB_TOKEN

GitHub Actions bot comments don't trigger other workflows (security feature).
Using PAT makes comments appear from user account, enabling workflow chaining.

## Testing

Create any issue and watch:
1. Auto-comment appears within 10 seconds
2. Claude responds with 🚀 reaction
3. Claude creates implementation PR

## Principles

- **ose**: Ultimate automation at management level
- **versioning-mindset**: Start simple, add conditions only when needed
- **subtraction-creates-value**: Removed all conditionals for simplicity