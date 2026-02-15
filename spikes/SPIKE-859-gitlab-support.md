# Spike #859: GitLab Support for /close-issue Slash Command

## Executive Summary

**Feasibility**: ✅ Highly feasible  
**Implementation Effort**: 4-6 hours  
**Recommendation**: Implement git remote detection approach with automatic platform routing

## Key Findings

### 1. GitLab MCP Tools Already Exist ✅

The dotfiles repository already includes a comprehensive GitLab MCP server at `mcp/servers/gitlab-mcp-server/` with full issue management capabilities:

- `gitlab_get_issue` - Fetch issue details
- `gitlab_create_issue` - Create new issues
- `gitlab_update_issue` - Update issues (including state changes)
- `gitlab_close_issue` - Close issues directly
- `gitlab_create_issue_comment` - Add comments to issues
- `gitlab_list_issue_comments` - List issue comments

### 2. Git Remote Detection Works Well 🎯

The prototype demonstrates reliable platform detection from git remotes:

```python
# Detects from current directory's git remote
$ git remote get-url origin
git@github.com:owner/repo.git     → Platform: github
git@gitlab.com:owner/project.git  → Platform: gitlab
```

### 3. Zero Configuration Approach Aligns with OSE Principle 🧭

The proposed implementation:
- Automatically detects platform from repository context
- No manual configuration required
- Works immediately when you `cd` into any repo
- Falls back gracefully to GitHub when platform unclear

## Prototype Results

Created working prototypes in `spikes/`:
1. `git_remote_detection.py` - Platform detection from git remotes
2. `close_issue_prototype.py` - Integration demonstration

The prototypes successfully:
- Detect GitHub vs GitLab from git remote URLs
- Parse issue numbers from both plain numbers and full URLs
- Route to appropriate MCP tools based on platform
- Handle additional prompt arguments for context

## Implementation Plan

### 1. Enhance close-issue.md Template

```markdown
# Current command
/close-issue 123
/close-issue https://github.com/owner/repo/issues/123

# Enhanced with optional prompt
/close-issue 123 "focus on performance"

# Auto-detects GitLab when in GitLab repo
cd ~/work/gitlab-project
/close-issue 456  # Uses GitLab MCP tools
```

### 2. Update Command Generator

Modify `.claude/command-templates/close-issue.md` to:
1. Detect platform from git remote or URL
2. Route to appropriate MCP tools (GitHub vs GitLab)
3. Support optional additional prompt argument
4. Maintain backward compatibility

### 3. Platform Detection Logic

```python
def detect_platform():
    # 1. Check if URL provided - extract platform
    # 2. Otherwise, check git remote
    # 3. Fall back to GitHub if unclear
    return platform, owner, repo
```

## Edge Cases Handled

1. **Multiple remotes**: Check origin first, then upstream
2. **Self-hosted GitLab**: Detect from URL patterns
3. **No git repo**: Fall back to GitHub with clear error
4. **Subgroups**: GitLab's `group/subgroup/project` structure

## Benefits

1. **Zero configuration** - Just works based on context
2. **Unified interface** - Same command for both platforms
3. **Natural workflow** - Aligns with existing developer patterns
4. **Future extensible** - Easy to add Bitbucket, Gitea, etc.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Platform misdetection | Clear error messages, manual override option |
| GitLab API differences | Already handled by existing GitLab MCP server |
| Authentication complexity | Both use existing auth (gh/glab CLI) |

## Recommendation

**Implement the git remote detection approach** because:

1. GitLab MCP tools already exist (no new MCP development needed)
2. Git remote detection is reliable and contextual
3. Implementation is straightforward (4-6 hours)
4. Maintains backward compatibility
5. Aligns perfectly with OSE principle (system adapts to context)

## Next Steps

1. Update `close-issue.md` template with platform detection
2. Add optional prompt argument support (addresses issue #858 too)
3. Test with real GitLab repositories
4. Update documentation

## Alternative Considered

**Separate commands** (`/close-github-issue`, `/close-gitlab-issue`)
- ❌ More commands to maintain
- ❌ Requires user to remember platform-specific commands
- ❌ Doesn't leverage contextual information

The git remote detection approach is clearly superior from a DevEx perspective.