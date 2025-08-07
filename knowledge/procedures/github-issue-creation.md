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
   - "retro" → Link retro-procedure
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

## Implementation

Create the issue with:
- Appropriate labels based on type
- Cross-referenced procedures in body
- Clear title following conventions
- Assignee if specified

## See Also

- [Issue to PR Workflow](issue-to-pr-workflow.md)
- [Close Issue Procedure](close-issue-procedure.md)