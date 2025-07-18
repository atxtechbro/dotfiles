# Vendor Agnosticism

Design systems to work with multiple providers. Never depend on just one.

## Core Principle

Build abstraction layers that let you switch providers based on availability, cost, or capability. Start with what matters most: your AI coding assistants.

## Example: Claude Code & Amazon Q

Both use the same MCP ecosystem, making switching seamless:

```bash
# Morning: Complex reasoning task
claude-code  # Claude excels at deep thinking

# Afternoon: AWS configuration  
qchat  # Amazon Q knows AWS deeply

# Either hits limits or goes down?
# Switch to the other instantly
```

Why this works:
- Same slash commands (`/close-issue`, `/retro`)
- Same MCP tools (`mcp__git__*`, `mcp__github__*`)
- Same file access
- Different strengths

Benefits:
- **No downtime**: Always have a working AI
- **400k context**: 200k + 200k tokens
- **Cost control**: Use free tiers of both
- **Right tool**: Match provider to task

## Beyond AI: The Pattern Applies Everywhere

- **Git hosting**: GitHub down? Push to GitLab mirror
- **Cloud providers**: AWS outage? Failover to GCP
- **Package registries**: npm down? Use local cache

The key: thin abstraction layers that make switching configuration, not code changes.

## Implementation

Start small. Get two AI providers working:
```bash
./utils/install-claude-code.sh
./utils/install-amazon-q.sh
```

Then expand the pattern as needed. No complex frameworks - just options when you need them.