# Universal Issue Implementation Template
# 
# This is the SINGLE SOURCE OF TRUTH for issue implementation instructions.
# Used by both:
# - Local /close-issue command (via GitHub raw URL injection)
# - GitHub Actions @claude workflow (with knowledge base injection)
#
# The {{ KNOWLEDGE_BASE }} placeholder below:
# - Remains empty for /close-issue (knowledge is preloaded)
# - Gets filled with aggregated knowledge for GitHub Actions
#
# Principle: systems-stewardship (single source of truth)

# Implement GitHub Issue #{{ ISSUE_NUMBER }}

You are implementing a GitHub issue with full access to the codebase knowledge, principles, and procedures.

{{ KNOWLEDGE_BASE }}

## Issue Details

**Issue Number**: #{{ ISSUE_NUMBER }}
**Title**: {{ ISSUE_TITLE }}
**Repository**: {{ REPO }}

### Issue Description

{{ ISSUE_BODY }}

## Implementation Instructions

### 1. Analyze the Issue
First, use `mcp__github__get_issue` to get the full issue context including any comments that might provide additional clarification.

### 2. Determine Approach
Based on the issue analysis, determine if this is:
- A bug fix requiring immediate implementation
- A feature request needing careful design
- A spike requiring research and documentation
- An invalid/duplicate issue to close

### 3. Follow Established Patterns
**IMPORTANT**: You have access to the full knowledge base (either injected above or preloaded in your context). Use it to:
- Follow the principles (tracer-bullets, versioning-mindset, OSE, etc.)
- Apply the appropriate procedures (git-workflow, worktree-workflow, etc.)
- Use conventional commit messages as documented
- Reference principles in commit trailers when applicable (e.g., `Principle: systems-stewardship`)

### 4. Implementation
- Create clean, focused changes that follow existing patterns
- Write code that follows the conventions you see in the codebase
- Use TodoWrite to track your progress through complex implementations
- Test your changes when possible

### 5. PR Creation
Ensure your commits:
- Have clear, conventional commit messages
- Reference the issue with "Closes #{{ ISSUE_NUMBER }}"
- Follow the git workflow standards from the knowledge base

## Key Principles to Apply

1. **Tracer Bullets**: Define your target, iterate with feedback, adjust based on results
2. **Versioning Mindset**: Iterate on existing code rather than rewriting
3. **Systems Stewardship**: Document decisions, maintain patterns, leave breadcrumbs
4. **Subtraction Creates Value**: Consider what to remove, not just what to add
5. **OSE**: Maintain elevated perspective, think systemically

## Available Tools

You have access to these tools:
- File operations: Read, Write, Edit, MultiEdit, LS, Glob, Grep
- Git operations: mcp__git (full git functionality)
- GitHub operations: mcp__github (API access)
- Task management: Task, TodoWrite
- Web tools: WebFetch, WebSearch
- Shell: Bash

## Important Reminders

- The knowledge base is your guide - use it actively
- This is not a blind implementation - you have full context
- Create PRs that match the quality of local development
- Follow the established patterns, don't reinvent them

Now proceed with implementing issue #{{ ISSUE_NUMBER }}.