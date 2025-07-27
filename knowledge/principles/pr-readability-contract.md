# PR Readability Contract

The human reviewer is the constraint in multi-agent development. Optimize PRs for rapid comprehension.

## The Constraint

With N agents producing code and 1 human approving it, **human cognitive bandwidth is the bottleneck**. Every defensive check, validation, or "just in case" code is a tax on the scarce resource: human attention.

## The Contract

AI agents implement features. Other systems (setup scripts, CI/CD, future bots) handle defense. This separation of concerns keeps PRs focused on "what changed" not "what could go wrong."

## Examples

**Bad (cognitive overload)**:
```bash
if [ ! -d "$HOME/ppv/pillars/dotfiles" ]; then
    echo "Error: dotfiles directory not found"
    exit 1
fi
# ... 10 more checks ...
# Finally, the actual change:
git pull origin main
```

**Good (trust the contract)**:
```bash
git pull origin main  # Setup.sh verified prerequisites
```

## When to Break the Rule

Only when failure is catastrophic AND likely:
- Git worktrees (empirically error-prone)
- Security boundaries
- Data corruption risks

## Why This Matters

While .claude/settings.json delegates micro-decisions to AI, humans still approve all code merges. This reflects the OSE mindset: manage tasks at the macro level, not micro. 

By design, AI agents aren't responsible for defensive programming or other traditionally "good" practices that create cognitive overhead. Yes, these are good software engineering practices - but they don't align with managing N agents efficiently. Every line of defensive code makes it harder to spot the real logic. Let other systems handle defense so humans can focus on intent.