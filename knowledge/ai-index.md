# AI Agent Index

Your starting point for understanding and working with this dotfiles repository.

## Quick Navigation

**When you need to...**

### Understand the Core Philosophy
- Read [The Goal: Throughput Definition](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/throughput-definition.md) - Our north star metric
- Review [Core Principles](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/) - Foundational truths
- Understand the [Snowball Method](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/snowball-method.md) - Knowledge accumulation

### Work with Git
- Follow [Git Workflow](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/procedures/git-workflow.md) - **ALWAYS START HERE**
- Use [Worktree Workflow](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/procedures/worktree-workflow.md) - For parallel development
- Apply [Tracer Bullets](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/tracer-bullets.md) - Iterative development

### Handle GitHub Tasks
- See [Issue to PR Workflow](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/procedures/issue-to-pr-workflow.md)
- Use GitHub MCP server for all GitHub operations
- Remember: Use mcp__github__ tools, not direct API calls

### Write or Modify Code
- Check [Coding Conventions](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/procedures/coding-conventions.md)
- Apply [Subtraction Creates Value](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/subtraction-creates-value.md) - Remove before adding
- Follow [Versioning Mindset](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/versioning-mindset.md) - Iterate, don't recreate

### Debug or Fix Issues
- Use [MCP Protocol Smoke Test](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/procedures/mcp-protocol-smoke-test.md) for MCP issues
- Apply [Systems Stewardship](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/systems-stewardship.md) - Document fixes
- See [Tool Discovery](/home/linuxmint-lp/ppv/pillars/dotfiles/mcp/tool-discovery.md) - Find the right tool

### Improve Documentation
- Follow [Transparency in Agent Work](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/transparency-in-agent-work.md)
- Apply [PR Readability Contract](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/principles/pr-readability-contract.md)
- Use absolute paths everywhere (no relative paths)

### Run Post-PR Retros
- See [Post-PR Mini Retro](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/procedures/post-pr-mini-retro.md)
- Consult [Personalities](/home/linuxmint-lp/ppv/pillars/dotfiles/knowledge/personalities/) for perspectives

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

Remember: The goal is AI agent management capability for 100x-1000x productivity.
