# GitHub Workflows Permission Workaround Procedure

## Purpose
Define the process for handling Claude's inability to modify GitHub Actions workflow files due to missing `workflows` permission.

## When to Use This Procedure
- Claude needs to modify any file in `.github/workflows/`
- You encounter the error: "refusing to allow a GitHub App to create or update workflow"
- Security fixes or improvements are needed for CI/CD pipelines

## Current Limitation
The `anthropics/claude-code-action@beta` GitHub App lacks `workflows` permission, preventing direct workflow file modifications.

## Workaround Process

### Step 1: Identify the Need
When Claude encounters workflow files that need modification:
1. Claude will document the required changes
2. Claude will explain why the changes are needed
3. Claude will provide specific implementation details

### Step 2: Manual Application
The human user must manually apply workflow changes:

#### Option A: Direct Edit (Simple Changes)
```bash
# Edit the workflow file directly
vim .github/workflows/target-workflow.yml

# Apply Claude's suggested changes
# Commit the changes
git add .github/workflows/target-workflow.yml
git commit -m "Apply Claude's workflow suggestions

Co-authored-by: Claude <claude@anthropic.com>"
git push
```

#### Option B: Claude-Guided Implementation (Complex Changes)
1. **Review Phase**: Claude analyzes current workflows and suggests improvements
2. **Specification Phase**: Claude provides detailed change specifications
3. **Implementation Phase**: Human applies changes following Claude's guidance
4. **Validation Phase**: Claude reviews the applied changes (if needed)

### Step 3: Validation
After manual application:
1. Verify workflow syntax is correct
2. Test workflow triggers if possible
3. Monitor first workflow execution
4. Document any issues encountered

## Alternative Solutions

### Solution 1: Personal Access Token (Advanced)
If frequent workflow modifications are needed:

1. **Create PAT**:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Create token with `workflow` scope
   - Add as repository secret `CLAUDE_WORKFLOWS_PAT`

2. **Update Workflow**:
   ```yaml
   - uses: anthropics/claude-code-action@beta
     with:
       claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
       github_token: ${{ secrets.CLAUDE_WORKFLOWS_PAT }}
   ```

3. **Security Considerations**:
   - Use dedicated service account
   - Regular token rotation
   - Monitor all workflow changes
   - Remove when GitHub App gets workflows permission

### Solution 2: Fork-Based Workflow
For organizations with strict security requirements:
1. Claude creates fork of repository
2. Claude makes changes in fork
3. Claude creates PR from fork to main repository
4. Human reviews and merges PR

## Communication Protocol

### When Claude Encounters Workflow Files
Claude should communicate:
```markdown
⚠️ **Workflow Permission Limitation**

I cannot directly modify `.github/workflows/[filename]` due to missing `workflows` permission on the GitHub App.

**Required Changes:**
- [Specific change 1]
- [Specific change 2]

**Implementation:**
Please manually apply these changes or use the PAT workaround documented in `/docs/github-workflows-permission-issue.md`.

**Validation:**
After applying changes, I can review the modifications if needed.
```

### When Human Needs Claude's Help
Human should:
1. Ask Claude to review proposed workflow changes
2. Request Claude to analyze current workflow issues
3. Get Claude's recommendations for workflow improvements
4. Use Claude for non-workflow file changes in the same task

## Escalation Path

### If Urgent Workflow Changes Are Needed
1. **Immediate**: Apply manual workaround
2. **Short-term**: Implement PAT solution if many changes expected
3. **Long-term**: Contact Anthropic about adding `workflows` permission

### If Workaround Doesn't Work
1. Check GitHub App permissions in repository settings
2. Verify PAT permissions and expiration (if using PAT approach)
3. Test with minimal workflow change first
4. Contact repository administrator

## Monitoring and Improvement

### Track This Issue
- Monitor [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) for updates
- Check Claude Code release notes for permission changes
- Test periodically if Claude can modify workflows

### Success Metrics
- Time from Claude recommendation to workflow implementation
- Number of manual interventions required
- Accuracy of Claude's workflow suggestions

### Process Improvement
- Document common workflow change patterns
- Create templates for frequent modifications
- Streamline validation process

## Related Documents
- `/docs/github-workflows-permission-issue.md` - Comprehensive issue analysis
- `/knowledge/procedures/git-workflow.md` - General git workflow procedures
- `/knowledge/principles/systems-stewardship.md` - Maintaining system reliability

---

**Last Updated**: 2025-08-04  
**Next Review**: When GitHub App permissions are updated  
**Owner**: Repository maintainers