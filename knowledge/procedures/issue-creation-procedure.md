# Issue Creation Procedure
# 
# This IS the implementation - the procedure documents itself by being the code.
# Used by /create-issue command (via injection)
#
# Principle: systems-stewardship (single source of truth, documentation as code)
# Principle: ose (operational-sensibility-expertise in issue management)

Create a new GitHub issue with validated labels and principle detection.

## Step 1: Gather Issue Details

Please provide:
1. **What you want to create an issue for**
2. **Any specific details or context**
3. **Whether this is for dotfiles or another repository**

If no details provided, prompt interactively for:
- Issue title
- Issue description/body
- Repository (default: atxtechbro/dotfiles)

## Step 2: Analyze Issue Type

Determine issue type based on content:
- Bug report → Keywords: "error", "fails", "broken", "bug"
- Feature request → Keywords: "feature", "add", "implement", "enhance"
- MCP tool error → Keywords: "tool error", "MCP"
- Procedure documentation → Keywords: "procedure", "document process", "ghost"
- General enhancement → Default for other requests

## Step 3: Detect Principles

Scan issue content for principle alignment:
- Direct mentions: "versioning-mindset", "OSE", "subtraction-creates-value"
- Keywords implying principles:
  - "simplify", "remove" → subtraction-creates-value
  - "iterate", "evolve" → versioning-mindset
  - "maintain", "steward" → systems-stewardship
  - "developer joy", "DX" → developer-experience
  - "rapid", "quick test" → tracer-bullets
  - "accumulate", "compound" → snowball-method

## Step 4: Select Labels

From the **Available Labels** section above, select appropriate labels based on:
- Issue type (bug, enhancement, documentation)
- Principles detected in Step 3
- Relevant areas (mcp, git, automation, etc.)

## Step 5: Build Issue Content

### Template Selection

| Issue Type | Template | Key Fields |
|------------|----------|------------|
| Bug report | issue.md | Steps to reproduce, expected behavior |
| Feature request | issue.md | Problem statement, proposed solution |
| MCP tool error | mcp-tool-error.md | Tool name, error message |
| Procedure documentation | procedure-documentation.md | Procedure name, steps |
| General | issue.md | Flexible format |

### Cross-Reference Procedures

Based on keywords, link relevant procedures:
- "MCP" → Link MCP-related procedures
- "worktree" → Link worktree-workflow
- "retro" → Link retro-procedure
- "git" → Link git-workflow
- "issue" → Link issue-to-pr-workflow

## Step 6: Preview Issue

Present a complete preview showing:
- **Title**: [proposed title]
- **Body**: [formatted content with template]
- **Labels**: [selected from available labels]
- **Repository**: [target repository]

Ask for confirmation or modifications.

## Step 7: Create the Issue

Upon confirmation:
1. Create the issue with selected labels
2. Return the issue URL
3. Log the creation for analytics

## Principle: subtraction-creates-value

This procedure replaces the auto-label workflow, removing a moving part while gaining:
- Immediate labeling (no GitHub Actions delay)
- Reliable label validation
- Interactive refinement
- Single source of truth

## See Also

- [Issue to PR Workflow](issue-to-pr-workflow.md)
- [Close Issue Procedure](close-issue-procedure.md)
- [Git Workflow](git-workflow.md)