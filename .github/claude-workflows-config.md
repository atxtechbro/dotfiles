# Claude Workflows Configuration

## Current Status: BLOCKED ❌

Claude cannot modify workflow files in `.github/workflows/` due to missing `workflows` permission on the GitHub App.

## Error Message
```
refusing to allow a GitHub App to create or update workflow .github/workflows/[filename] without workflows permission
```

## Affected Operations
- ❌ Creating new workflow files
- ❌ Modifying existing workflow files  
- ❌ Deleting workflow files
- ✅ Reading workflow files (works fine)

## Quick Reference

### For Humans
When Claude suggests workflow changes:
1. Claude will provide detailed change specifications
2. Manually apply the changes to the workflow files
3. Test the workflow after changes
4. Consider the PAT workaround for frequent modifications

### For Claude
When encountering workflow files:
```markdown
⚠️ **Workflow Permission Limitation**

I cannot modify `.github/workflows/[filename]` due to missing `workflows` permission.

**Required Changes:**
[List specific changes needed]

**Manual Implementation Required:**
Please apply these changes manually or see `/docs/github-workflows-permission-issue.md` for the PAT workaround.
```

## Workaround Options

### Option 1: Manual Application (Recommended)
- Human applies Claude's suggested changes
- Preserves security model
- No additional setup required

### Option 2: Personal Access Token (Advanced)
- Create PAT with `workflow` scope
- Store as `CLAUDE_WORKFLOWS_PAT` secret
- Update workflow to use PAT instead of `GITHUB_TOKEN`
- **Security Risk**: Broader permissions than needed

### Option 3: Wait for GitHub App Update
- Monitor `anthropics/claude-code-action` for updates
- Anthropic adds `workflows` permission to their app
- No changes needed once updated

## Related Files
- `/docs/github-workflows-permission-issue.md` - Comprehensive analysis
- `/knowledge/procedures/github-workflows-permission-workaround.md` - Step-by-step procedures

## Tracking
- **Issue**: #1168
- **Priority**: HIGH (blocks security fixes)
- **Owner**: Pending Anthropic response

---
*Last updated: 2025-08-04*