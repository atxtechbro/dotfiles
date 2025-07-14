# Cookie Crumbs Documentation Pattern

Leave "cookie crumbs" - brief implementation notes - that help orient future work without over-documenting. The pattern balances knowledge preservation with token economy constraints.

## Core Principle
Document the **why** and **discovery process**, not just the **what**. Future maintainers need context about decisions, constraints, and patterns discovered during implementation.

## Implementation Guidelines

### What to Document
- **Decision rationale**: Why this approach over alternatives
- **Constraint discoveries**: What limitations or requirements emerged
- **Pattern insights**: Reusable approaches discovered during work
- **Failure modes**: What didn't work and why (prevents repetition)
- **Integration points**: How this connects to existing systems

### What NOT to Document
- Implementation details fully covered in code
- Obvious steps that tools make clear
- Temporary debugging information
- Overly specific examples that won't generalize

## Examples from Practice

### Good Cookie Crumbs
**From gitignore work:**
```markdown
# MCP Server Gitignore Patterns

## .pyc Files
- Python bytecode files auto-generated during imports
- Pattern: `**/*.pyc` covers all subdirectories
- Alternative `__pycache__/` pattern rejected - less specific

## Virtual Environment Detection
- Pattern: `**/venv/` and `**/.venv/` 
- Covers both common naming conventions
- Discovered: uv uses .venv, venv uses venv
```

**From slash command work:**
```markdown
# Slash Command Generation

How slash commands actually work (note to future self who will forget):

1. **Templates** in `.claude/command-templates/` - the source files
2. **Generator** (`utils/generate-claude-commands.sh`) - runs during setup.sh
3. **Output** in `~/.claude/commands/` - what Claude Code actually reads

The analytics logging gets baked in at "compile time" by the generator.
```

### Anti-Patterns (Avoid These)

**Over-documentation:**
```markdown
# How to Add a File to Git
1. Use git add filename
2. Use git commit -m "message"
3. Use git push
```

**Under-documentation:**
```markdown
# Fixed the thing
Updated the file.
```

**Implementation-heavy:**
```markdown
# Function Implementation
```python
def process_data(data):
    # 50 lines of code with no context
```

## Token Economy Considerations

### High-Value Documentation
- **Constraint discoveries**: Save future investigation time
- **Pattern insights**: Reusable across projects
- **Integration gotchas**: Prevent future breakage
- **Decision context**: Why this choice was made

### Low-Value Documentation
- **Obvious workflows**: Standard git commands
- **Tool-generated content**: README boilerplate
- **Temporary solutions**: One-off fixes
- **Debugging artifacts**: Console output traces

## Practical Implementation

### During Development
1. **Capture insights immediately**: Don't trust memory for complex discoveries
2. **Note constraint discoveries**: When you hit limitations, document them
3. **Record pattern insights**: When you discover reusable approaches
4. **Document integration points**: How this connects to existing systems

### During Review
1. **Assess knowledge preservation**: Will future maintainers understand this?
2. **Check token efficiency**: Is this worth the context window space?
3. **Validate practical value**: Does this help with actual future work?
4. **Ensure appropriate detail level**: Neither too sparse nor too verbose

## Integration with Existing Systems

### Relationship to Other Principles
- **Systems Stewardship**: Cookie crumbs support knowledge transfer
- **Versioning Mindset**: Each iteration adds learning context
- **Subtraction Creates Value**: Avoid documentation inventory buildup
- **Token Economy**: Optimize for AI context window efficiency

### File Location Guidelines
- **Procedures**: Process-oriented cookie crumbs
- **README files**: Integration and setup insights
- **Inline comments**: Implementation decision context
- **Commit messages**: Brief decision rationale

## Quality Indicators

### Good Cookie Crumbs
- Answer "why" questions future maintainers will have
- Provide context for non-obvious decisions
- Include constraint discoveries and workarounds
- Reference related principles or patterns

### Poor Cookie Crumbs
- Repeat information available elsewhere
- Focus on implementation details without context
- Include temporary or debugging information
- Lack connection to broader system patterns

## Evolution Guidelines

### When to Update
- **New constraints discovered**: Add to existing documentation
- **Pattern improvements**: Update with better approaches
- **Integration changes**: Reflect new system connections
- **Failure modes**: Add newly discovered anti-patterns

### When to Remove
- **Obsolete constraints**: No longer applicable
- **Superseded patterns**: Better approaches available
- **Broken integrations**: System connections changed
- **Validated assumptions**: No longer need documentation

This pattern ensures sustainable knowledge preservation while respecting token economy constraints and supporting effective agent-human collaboration.