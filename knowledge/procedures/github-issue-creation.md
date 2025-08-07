# GitHub Issue Creation

Intelligent issue creation that auto-detects type, suggests templates, and links relevant procedures.

## When to Use This

When users request "create a GitHub issue for..." or need to document a new task, bug, or enhancement.

## Decision Tree

1. **Analyze the request** to determine issue type:
   - Bug report → Use bug template
   - Feature request → Use feature template
   - MCP tool error → Use mcp-tool-error template
   - Procedure documentation → Use procedure-documentation template
   - General enhancement → Use enhancement template

2. **Scan for keywords** to link relevant procedures:
   - "MCP" → Link MCP-related procedures
   - "worktree" → Link worktree-workflow
   - "retro" → Link post-pr-mini-retro
   - "git" → Link git-workflow

3. **Auto-populate context**:
   - Related principles from knowledge/principles/
   - Existing procedures that might help
   - Recent similar issues (if any)

## Template Mapping

| Request Contains | Suggested Template | Key Fields |
|-----------------|-------------------|------------|
| "error", "fails", "broken", "bug" | issue.md (bug report) | Steps to reproduce, expected behavior |
| "feature", "add", "implement", "enhance" | issue.md (enhancement) | Problem statement, proposed solution |
| "tool error" | mcp-tool-error.md | Tool name, error message, reproduction |
| "procedure", "document process", "ghost" | procedure-documentation.md | Procedure name, steps, trigger |
| General request | issue.md | Flexible format for any issue type |

## Available Templates

- **issue.md** - General purpose template for bugs, features, questions
- **mcp-tool-error.md** - Specific to MCP tool failures (auto-assigns)
- **procedure-documentation.md** - For capturing ghost procedures

## Smart Labeling

### Available Labels
The repository has these labels available:
- **Type**: `bug`, `enhancement`, `feature`, `documentation`, `question`
- **Components**: `mcp`, `github-actions`, `git`, `nvim`, `automation`
- **Status**: `help wanted`, `good first issue`, `wontfix`, `duplicate`, `invalid`
- **Areas**: `developer-experience`, `security`, `configuration`, `setup`, `ci-cd`
- **AI**: `ai`, `amazon-q`
- **Other**: `filesystem`, `debugging`, `modularity`, `github`, `github-integration`, `git-hooks`, `neovim`, `ci-failure`

### Labeling Logic

1. **First, check label existence**:
   - Run `gh label list` to get current labels
   - Only use labels that exist in the repository

2. **Apply labels based on content**:
   - Bug reports → `bug`
   - Feature requests → `enhancement` or `feature`
   - MCP-related → `mcp`
   - GitHub Actions → `github-actions`, `automation`
   - Configuration changes → `configuration`
   - CI/CD issues → `ci-cd`, `ci-failure` (if build failed)
   - Security concerns → `security`
   - Developer tooling → `developer-experience`

3. **Be minimal**: Only add labels that add clear value

## Implementation

Create the issue with:
- Smart label selection (check existence first with `gh label list`)
- Cross-referenced procedures in body
- Clear title following conventions
- Assignee if specified
- Use `gh issue create` with `--label` only for existing labels

**Example**:
```bash
# First check available labels
gh label list

# Then create issue with appropriate existing labels
gh issue create --title "Fix: Issue title" --body "..." --label "bug,automation"
```

## Important Notes

- **Never use labels that don't exist** - this will cause the issue creation to fail
- The auto-label workflow has been removed per issue #1236
- Claude now handles labeling directly at issue creation time
- Follow the **subtraction-creates-value** principle - fewer moving parts

## See Also

- [Issue to PR Workflow](issue-to-pr-workflow.md)
- [Close Issue Procedure](close-issue-procedure.md)