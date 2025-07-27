# PR Readability Contract

The human reviewer is the constraint in multi-agent development. Optimize diffs for rapid comprehension.

## The Constraint

With N agents producing code and 1 human approving it, **human cognitive bandwidth is the bottleneck**. Every defensive check, validation, or "just in case" code is a tax on the scarce resource: human attention.

## The Contract

Design by contract: AI agents are responsible for implementing the requested functionality - nothing more. Everything else (defensive checks, error handling, logging, performance optimization, code style perfection) is delegated to other systems or future passes. This keeps diffs focused on the actual change.

## Examples of Non-Bottleneck Optimizations to Avoid

- Defensive programming checks
- Extensive error handling
- Performance micro-optimizations  
- Code style perfection
- Comprehensive logging
- Edge case handling
- "Future-proofing" abstractions

## When to Break the Rule

Only when failure is catastrophic AND likely:
- Git worktrees (empirically error-prone)

## Why This Matters

Theory of Constraints: optimize the bottleneck (human attention), not the non-bottlenecks. While .claude/settings.json delegates micro-decisions to AI, humans still review all diffs. This reflects the OSE mindset: manage at the macro level.

AI agents should optimize for the constraint by delivering the cleanest possible diff of the requested feature. All the "good engineering practices" that bloat diffs? Delegate them elsewhere. The human reviewer scanning the diff needs to see intent, not infrastructure.