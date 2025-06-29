# Close Issue Workflow

The `/close-issue` command is for **completing and implementing issues**, not just closing them.

## Key Understanding

**Command name vs intent:**
- **Name suggests**: "close" the issue in GitHub
- **Actual intent**: "complete" the issue by implementing it, creating a PR that closes it when merged

## Workflow Overview

1. **Analyze the issue** - Determine if it needs implementation
2. **Default to implementation** - Most issues should be implemented
3. **Quick close only when appropriate** - Already resolved, duplicate, or invalid

## When to Implement (Most Common)

Create a PR that implements the issue when:
- Bug reports with clear reproduction steps
- Feature requests (especially if from maintainer)
- Documentation improvements
- Enhancements with clear value
- Any valid, unaddressed issue

The PR should include "Closes #NUMBER" to auto-close the issue when merged.

## When to Quick Close (Less Common)  

Only close without implementation when:
- Already implemented (reference the PR)
- Duplicate (reference original issue)
- Invalid or out of scope
- Question that's been answered
- No longer relevant

## Remember

- Issues exist for a reason - someone took time to create them
- When in doubt, implement rather than close
- The "close" in `/close-issue` means "complete the work"
- Closing prematurely wastes the issue creator's effort

This procedure helps prevent the ~10% misinterpretation rate where AI literally closes issues instead of implementing them.

Principle: versioning-mindset