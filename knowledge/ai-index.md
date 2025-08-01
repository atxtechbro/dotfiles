# AI Agent Index

Your starting point for understanding and working with this dotfiles repository.

> **Note**: All paths are relative to the `knowledge/` directory.  
> Repository typically located at: `~/ppv/pillars/dotfiles/`

## Quick Navigation

**When you need to...**

### Understand the Core Philosophy
- Read [The Goal: Throughput Definition](throughput-definition.md) - Our north star metric
- Review [Core Principles](principles/) - Foundational truths
- Understand the [Snowball Method](principles/snowball-method.md) - Knowledge accumulation

### Work with Git
- Follow [Git Workflow](procedures/git-workflow.md) - **ALWAYS START HERE**
- Use [Worktree Workflow](procedures/worktree-workflow.md) - For parallel development
- Apply [Tracer Bullets](principles/tracer-bullets.md) - Iterative development

### Handle GitHub Tasks
- Create issues with [GitHub Issue Creation](procedures/github-issue-creation.md) - Smart template selection
- See [Issue to PR Workflow](procedures/issue-to-pr-workflow.md) - High-level flow
- Follow [Close Issue Procedure](procedures/close-issue-procedure.md) - Detailed steps
- Use GitHub MCP server for all GitHub operations
- Remember: Use mcp__github__ tools, not direct API calls

### Write or Modify Code
- Check [Coding Conventions](procedures/coding-conventions.md)
- Apply [Subtraction Creates Value](principles/subtraction-creates-value.md) - Remove before adding
- Follow [Versioning Mindset](principles/versioning-mindset.md) - Iterate, don't recreate

### Debug or Fix Issues
- Use [MCP Protocol Smoke Test](procedures/mcp-protocol-smoke-test.md) for MCP issues
- Follow [MCP Error Reporting](procedures/mcp-error-reporting.md) when MCP tools fail
- Apply [Systems Stewardship](principles/systems-stewardship.md) - Document fixes

### Improve Documentation
- Follow [Transparency in Agent Work](principles/transparency-in-agent-work.md)
- Apply [PR Readability Contract](principles/pr-readability-contract.md)
- Use relative paths for portability

### Capture Ghost Procedures
- Follow [Procedure Creation](procedures/procedure-creation.md) - Document the undocumented!
- Many procedures exist but aren't written down yet
- If you do it twice, write it down
- Transform tribal knowledge into systems

### Run Post-PR Retros
- See [Post-PR Mini Retro](procedures/post-pr-mini-retro.md)
- Consult [Personalities](personalities/) for perspectives

### When MCP Tools Don't Work
- Follow [MCP Error Reporting](procedures/mcp-error-reporting.md) - We control these servers, we'll fix them!
- Creates self-healing systems through proper issue tracking
- Remember: 80% core work, 20% documenting issues

## Structure
- `throughput-definition.md` - **The North Star**: Defines throughput as AI agent management capability for 100x-1000x productivity
- `principles/` - Foundational truths that rarely change
- `procedures/` - Actionable processes that evolve
- `personalities/` - Consultant personas for specialized perspectives

## Editing Guidelines
When editing these foundational files, keep changes small and easy to approve. Avoid long code blocks or extensive additions. Every edit should be easy to say "yes" to without nitpicking.

## Critical Rules

1. **ALWAYS use MCP tools** instead of bash for git operations
2. **ALWAYS check git status** before creating branches
3. **ALWAYS use absolute paths** in file operations
4. **NEVER commit directly to main** without explicit permission
5. **NEVER create files** unless absolutely necessary - prefer editing

## Tool Selection Guide

| Task | Use These Tools |
|------|----------------|
| Git operations | mcp__git__* tools |
| GitHub operations | mcp__github__* tools |
| File search | Grep, Glob, or Task (for complex searches) |
| File editing | Edit, MultiEdit |
| File creation | Write (only when necessary) |
| Web browsing | mcp__playwright__* tools |
| Documentation lookup | Read this index first, then specific docs |
| Run shell commands | Bash (prefer MCP tools when available) |

Remember: The goal is AI agent management capability for 100x-1000x productivity.
