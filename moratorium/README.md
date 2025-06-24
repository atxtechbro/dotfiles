# Moratorium

The moratorium directory contains principles or procedures that have been temporarily suspended from active use in the knowledge base system prompts.

## Purpose

Sometimes a principle or procedure may need re-evaluation:
- It might be overcorrecting for issues specific to certain AI assistants
- Its effectiveness in different contexts needs assessment
- We want to test system behavior without certain constraints

## Process

1. **Move to Moratorium**: Use `git mv` to move the file from `knowledge/` to `moratorium/`, preserving the subdirectory structure
2. **Test Without**: Assess system behavior without the principle/procedure in active prompts
3. **Decision Point**: After testing, either:
   - **Restore**: Move back to `knowledge/` if it proves beneficial
   - **Remove**: Delete entirely if it's no longer needed
   - **Keep in Moratorium**: Continue testing for longer period

## Current Items

### Principles
- `do-dont-explain.md` - Testing Claude Code's natural behavior without explicit "act agentically" constraints

## History

When items are moved in or out of moratorium, document the decision here:

- **2025-06-24**: `do-dont-explain.md` moved to moratorium to test Claude Code's behavior without this constraint (Issue #549)

Principle: tracer-bullets