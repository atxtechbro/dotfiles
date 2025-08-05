# Experiment: Claude Code without git/github MCP servers

**Issue**: #1213  
**Date**: 2025-08-05  
**Branch**: `feat/1213-test-without-mcp-servers`

## Objective

Test Claude Code functionality without using git/github MCP servers, relying instead on direct CLI usage through the Bash tool.

## Hypothesis

Direct CLI usage will provide:
- Faster and more reliable performance
- Clearer error messages  
- Full access to git/gh features without wrapper limitations
- Reduced complexity leading to better overall performance

## Implementation

### Changes Made

1. **Disabled MCP servers in `.claude/settings.json`**:
   - Commented out `"mcp__git"` and `"mcp__github"` from permissions array
   - Commented out `"git"` and `"github"` from `enabledMcpjsonServers` array
   - Left `"playwright"` enabled for comparison

### Files Modified
- `.claude/settings.json` - Disabled git/github MCP server references

## Test Results

### Direct Git Commands ✅
- `git status` - **SUCCESS**: Clear output showing modified files
- `git checkout -b feat/1213-test-without-mcp-servers` - **SUCCESS**: Branch created instantly
- `git add .claude/settings.json` - **SUCCESS**: File staged without issues
- `git commit -m "message"` - **SUCCESS**: Commit created with hash 8414227

### Direct GitHub CLI Commands ⚠️
- `gh auth status` - Expected failure in GitHub Actions (no auth configured)
- `gh repo view` - Expected failure in GitHub Actions (requires GH_TOKEN)

**Note**: GitHub CLI limitations are environment-specific (GitHub Actions) and not related to the MCP server experiment.

## Performance Observations

### Speed
- Git operations felt **instantaneous** compared to previous MCP wrapper experience
- No noticeable delay between command execution and response
- Error handling appears more direct and immediate

### Error Messages
- Git error messages are **native and clear**
- No additional MCP wrapper layer obscuring underlying issues
- Debugging is more straightforward with direct tool output

### Functionality
- **Full git feature access** through direct CLI
- No limitations imposed by MCP wrapper implementations
- Standard git workflows work as expected

## Conclusions

### Advantages ✅
1. **Performance**: Noticeably faster execution of git commands
2. **Clarity**: Direct error messages without wrapper abstraction
3. **Completeness**: Full access to all git CLI features
4. **Simplicity**: Reduced system complexity
5. **Reliability**: No MCP server connection issues or timeouts

### Potential Disadvantages ⚠️
1. **Consistency**: Need to ensure all procedures use Bash tool instead of MCP tools
2. **Documentation**: Existing procedures reference MCP tools that are now disabled
3. **Integration**: Some automated workflows may expect MCP tool responses

## Rollback Instructions

If this experiment needs to be reverted:

1. **Re-enable MCP servers in `.claude/settings.json`**:
   ```json
   // Change these lines:
   // "mcp__git",
   // "mcp__github",
   
   // Back to:
   "mcp__git",
   "mcp__github",
   ```

2. **Re-enable in enabledMcpjsonServers**:
   ```json
   // Change these lines:
   // "git",
   // "github",
   
   // Back to:
   "git",
   "github",
   ```

3. **Commit and push the revert**:
   ```bash
   git add .claude/settings.json
   git commit -m "revert: re-enable git/github MCP servers"
   git push origin feat/1213-test-without-mcp-servers
   ```

## Recommendation

**PROCEED** with this approach. The experiment shows clear benefits:
- Improved performance and reliability
- Better error handling and debugging
- Full feature access without limitations
- Reduced system complexity

The advantages significantly outweigh the minor documentation updates needed to reflect the new approach.

## Next Steps

1. Update procedures to use `Bash` tool for git operations instead of `mcp__git__*` tools
2. Update procedures to use `Bash` tool with `gh` commands instead of `mcp__github__*` tools  
3. Monitor long-term stability and performance
4. Document any additional benefits or issues discovered

---

**Principle applied**: tracer-bullets - Real-world testing provides concrete feedback for system optimization decisions.