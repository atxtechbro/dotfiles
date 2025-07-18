# Vendor Agnosticism

Switch between AI providers fluidly. Claude Code and Amazon Q working together, not competing.

## Core Insight

The real power isn't choosing one AI provider - it's using multiple providers interchangeably throughout your day. Claude Code for deep thinking, Amazon Q for AWS tasks, back to Claude when Q hits limits. Fluid, natural switching.

## Why This Works

**Claude Code** and **Amazon Q CLI** both:
- Use the same MCP server ecosystem
- Support identical slash commands
- Access the same files and tools
- Remember conversation context

The only difference? The conversation interface.

## Natural Switching Patterns

```bash
# Morning: Complex architecture design
claude-code  # Claude's reasoning shines here

# Afternoon: AWS deployment setup  
qchat  # Q knows AWS services deeply

# Evening: Bug investigation
claude-code  # Back to Claude for detective work

# Late night: Quick fixes
qchat  # Q still has fresh context
```

## The Key: Shared Abstractions

### Slash Commands Work Everywhere
- `/close-issue 919` - Same in both
- `/retro` - Same reflection process
- `/compact` - Same quick mode

### MCP Tools Stay Consistent
- `mcp__git__*` - Same git operations
- `mcp__filesystem__*` - Same file access
- `mcp__github__*` - Same GitHub integration

## Practical Benefits

1. **Never blocked**: One down? Use the other
2. **Context management**: 200k + 200k = 400k tokens
3. **Cost optimization**: Free tiers of both
4. **Strength matching**: Right tool for each task

## Implementation

Just install both and go:
```bash
./utils/install-claude-code.sh
./utils/install-amazon-q.sh
./mcp/generate-mcp-config.sh
```

Then switch naturally based on:
- What's working
- What's cheaper  
- What's better for this specific task
- Which has cleaner context

No complex abstractions. No frameworks. Just two tools that work the same way, ready when you need them.