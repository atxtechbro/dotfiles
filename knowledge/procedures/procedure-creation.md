# Procedure Creation

How to capture ghost procedures and improve existing ones, inspired by Sam Carpenter's "Work the System".

## Ghost Procedures

Ghost procedures are the unwritten processes we follow repeatedly but haven't documented. Like Sam Carpenter discovered after 25 years of firefighting at his telephone answering service, these hidden procedures are everywhere - we just need to capture them.

## When to Create a New Procedure

Create a procedure when you:
- Do something more than twice
- Explain how to do something
- Find yourself saying "the way we usually..."
- Discover an undocumented pattern
- Hit the same problem repeatedly
- Notice tribal knowledge that should be shared

## When to Improve Existing Procedures

Improve a procedure when:
- It feels incomplete or unclear
- You had to figure out missing steps
- The context has changed
- You found a better way
- It references outdated tools/methods

## Creating a New Procedure

1. **Check if it exists** - Look in `procedures/` first
2. **Name it clearly** - Use verb-noun format (e.g., `manage-dependencies.md`)
3. **Start simple** - Even a rough draft is better than nothing
4. **Follow the template** below
5. **Link it** - Add to relevant sections in ai-index.md

**Quick capture option**: Use the [Procedure Documentation issue template](/.github/ISSUE_TEMPLATE/procedure-documentation.md) to quickly document a ghost procedure for later formalization.

## Procedure Template

```markdown
# [Procedure Name]

Brief description of what this procedure accomplishes.

## When to Use This

Specific situations or triggers that indicate this procedure should be followed.

## Prerequisites

- Required tools, access, or knowledge
- Links to related procedures

## Procedure

1. **Step name** - Clear action
   - Sub-step if needed
   - Expected outcome

2. **Next step** - What to do next
   - Details
   - Validation

## Common Issues

- Known problems and solutions
- Edge cases to watch for

## See Also

- Related procedures
- Relevant principles
```

## Improving Procedures

When improving:
1. **Make the edit** - Don't create v2 files (versioning mindset)
2. **Add what's missing** - Fill gaps you discovered
3. **Remove what's outdated** - Subtraction creates value
4. **Test it mentally** - Would this help someone new?

## The Carpenter Principle

Sam Carpenter transformed his business by documenting every procedure, no matter how small. After 25 years of chaos, systematic documentation gave him control. Every ghost procedure you capture reduces future firefighting.

Remember: **Perfect is the enemy of good**. A rough procedure that exists beats a perfect one that doesn't.

## Examples of Ghost Procedures to Capture

- How we handle MCP server updates
- Steps for debugging flaky tests
- Process for reviewing PRs
- Method for setting up new machines
- Workflow for handling service outages

Start capturing - every documented procedure is one less fire to fight!