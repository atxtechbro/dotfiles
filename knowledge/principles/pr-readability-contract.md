# PR Readability Contract

Optimize pull requests for human review by moving defensive checks out of core logic.

## The Problem

Defensive programming inline with business logic creates cognitive overload during PR review. Reviewers must mentally filter out defensive scaffolding to understand the actual changes.

## The Solution

Establish contracts at system boundaries (setup scripts, CI/CD, infrastructure) so core logic can be clean and readable.

## When to Be Defensive Inline

- **Error-prone workflows**: Git worktrees, complex git operations where failures are common and costly
- **User-facing APIs**: External interfaces with unpredictable input
- **Critical failure paths**: Where silent failures would cause significant damage
- **Security boundaries**: Authentication, authorization, data validation at trust boundaries

## When to Trust the Contract

- **After setup scripts have run**: When prerequisites are verified by infrastructure
- **In controlled environments**: Internal tools with known constraints
- **When prerequisites are verified elsewhere**: Downstream of validation layers
- **Pure business logic**: Focus on the "what" not the "how to protect"

## Examples

**Bad (cognitive overload in PR)**:
```bash
# In a slash command script
if [ ! -d "$HOME/ppv/pillars/dotfiles" ]; then
    echo "Error: dotfiles directory not found"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Error: git is not installed"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN not set"
    exit 1
fi

# Finally, the actual logic...
git pull origin main
```

**Good (trust the contract)**:
```bash
# Prerequisites verified by setup.sh
git pull origin main
```

## Relationship to Other Principles

- **[OSE](ose.md)**: Review at appropriate altitude - PRs should show intent, not implementation details
- **[Systems Stewardship](systems-stewardship.md)**: Put defensive checks in system setup, not runtime
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Remove inline checks that don't add value to the reviewer
- **[Selective Optimization](selective-optimization.md)**: Optimize for the common case (setup worked) not the edge case

## The Deeper Insight

This isn't about being cavalier with error handling. It's about recognizing that **PR review is a scarce resource** and optimizing for reviewer comprehension. Every defensive check in a PR is a tax on understanding the actual change.

Put another way: defensive programming is system design, not feature implementation. Design your systems to be defensive at the boundaries so your features can be clear at the center.