# PR Readability Contract

The human reviewer is the constraint in multi-agent development. Optimize PRs for easy review.

## The Constraint

With N agents producing code and 1 human approving it, **human cognitive bandwidth is the bottleneck**. Every defensive check, validation, or "just in case" code is a tax on the scarce resource: human attention.

## The Contract

Design by contract: AI agents are responsible for implementing the requested functionality - nothing more. Everything else (defensive checks, error handling, logging, performance optimization, code style perfection) is delegated to other systems or future passes. This keeps PRs focused on the actual change, making them quick to eyeball.

## Examples of Non-Bottleneck Optimizations to Avoid

- Defensive programming checks
- Extensive error handling
- Performance micro-optimizations  
- Code style perfection
- Comprehensive logging
- Edge case handling
- "Future-proofing" abstractions
- **Colorful echo statements**: Multiple colored status messages bloat diffs and fatigue reviewers

### Negative Example: Logging Bloat

**Bad (50% logging noise):**
```bash
if command -v claude &> /dev/null; then
    echo "Configuring Claude Code imperative settings..."
    claude config set -g autoUpdate true 2>/dev/null || echo -e "${YELLOW}Warning: Could not set autoUpdate${NC}"
    claude config set -g preferredNotifChannel terminal_bell 2>/dev/null || echo -e "${YELLOW}Warning: Could not set preferredNotifChannel${NC}"
    echo -e "${GREEN}✓ Claude Code imperative settings configured${NC}"
fi
```

**Good (focused on the change):**
```bash
if command -v claude &> /dev/null; then
    claude config set -g autoUpdate true 2>/dev/null
    claude config set -g preferredNotifChannel terminal_bell 2>/dev/null
fi
```

The second version makes the actual change immediately visible. Logging can be added in a separate PR if needed.

## When to Break the Rule

Only when failure is catastrophic AND likely:
- Git worktrees (empirically error-prone)

## Why This Matters

Theory of Constraints: optimize the bottleneck (human attention), not the non-bottlenecks. While proposed diffs get auto-approved, humans still review at the PR level. This reflects the OSE mindset: manage at the macro level.

AI agents should optimize for the constraint by delivering PRs that are easy to review - clean, focused changes that can be quickly eyeballed. All the "good engineering practices" that bloat PRs? Delegate them elsewhere. When scanning a PR, the human needs to see intent, not infrastructure.