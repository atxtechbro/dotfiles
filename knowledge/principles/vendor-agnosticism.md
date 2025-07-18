# Vendor Agnosticism

Design every system layer to be replaceable. Today's perfect vendor is tomorrow's constraint.

## Core Concept

Vendor agnosticism is the practice of designing systems that can seamlessly switch between different service providers, tools, and platforms. It's about maintaining optionality at every layer of your stack - from AI providers to cloud infrastructure.

This principle emerged from real-world pain: AI providers change their interfaces, git platforms have outages, cloud vendors alter their pricing. Without abstraction layers, each change requires painful migrations.

## Why This Matters

1. **Resilience**: When GitHub is down, can you still ship? When your AI provider has an outage, can you still code?
2. **Negotiation Power**: Lock-in destroys leverage. Portability creates options.
3. **Innovation Adoption**: New tools emerge constantly. Abstractions let you adopt without rewriting everything.
4. **Cost Optimization**: Switch providers based on value, not sunk cost.

## Multi-Layer Application

### AI Provider Layer
- **Problem**: Claude Code vs Amazon Q vs future AI tools have different interfaces
- **Solution**: Unified slash commands that work across providers
- **Example**: `/close-issue` works identically in any AI client

### Git Platform Layer
- **Problem**: GitHub, GitLab, and Gitea have different CLIs and APIs
- **Solution**: Abstracted commands that delegate to platform-specific tools
- **Example**: `create-pr` delegates to `gh`, `glab`, or generic git

### Cloud Infrastructure Layer
- **Problem**: AWS, GCP, and Azure have incompatible services
- **Solution**: Infrastructure as code with provider-agnostic modules
- **Example**: Terraform modules that abstract cloud-specific resources

### Tool Ecosystem Layer
- **Problem**: Build tools, package managers, and CLIs change over time
- **Solution**: Wrapper scripts that normalize interfaces
- **Example**: `build.sh` that works with npm, yarn, or pnpm

## Implementation Patterns

### The Abstraction Layer Pattern
```bash
# Bad: Direct vendor coupling
gh pr create --title "Fix" --body "Details"

# Good: Abstracted interface
create-pr "Fix" "Details"  # Implementation handles provider detection
```

### The Fallback Pattern
```bash
# Primary provider
if command -v gh &> /dev/null; then
    gh pr create "$@"
# Fallback to alternative
elif command -v glab &> /dev/null; then
    glab mr create "$@"
# Ultimate fallback
else
    git push && echo "Create PR manually"
fi
```

### The Configuration Pattern
```yaml
# config.yml
provider: github  # Easy to switch to: gitlab, gitea, etc.
ai_client: claude  # Easy to switch to: amazonq, openai, etc.
```

## Practical Guidelines

1. **Identify Lock-in Points**: Audit code for vendor-specific assumptions
2. **Create Thin Wrappers**: Just enough abstraction to enable switching
3. **Document Provider Requirements**: What features does each provider need?
4. **Test Portability**: Regularly verify you can switch providers
5. **Plan Migration Paths**: Document how to move between providers

## Anti-Patterns to Avoid

- **Over-abstraction**: Don't create complex frameworks for simple needs
- **Lowest Common Denominator**: Use provider strengths through feature detection
- **Premature Abstraction**: Wait until you need a second provider
- **Hidden Coupling**: Watch for implicit vendor assumptions

## Relationship to Other Principles

- **[Versioning Mindset](versioning-mindset.md)**: Each abstraction is a version that evolves
- **[Subtraction Creates Value](subtraction-creates-value.md)**: Remove vendor-specific complexity
- **[Systems Stewardship](systems-stewardship.md)**: Abstractions are systems to maintain
- **[Invent and Simplify](invent-and-simplify.md)**: Find simple abstractions that enable flexibility
- **[OSE](ose.md)**: Elevated perspective helps identify vendor dependencies

## Real-World Application

**Scenario**: Your team uses GitHub exclusively. Should you use `gh` directly?

**Vendor-locked approach**: Embed `gh` commands everywhere, assuming GitHub forever.

**Vendor-agnostic approach**: 
1. Create wrapper functions for common operations
2. Use `gh` as the implementation detail
3. When GitLab migration happens, update wrappers only
4. Zero changes to actual workflow code

## The Deeper Truth

Vendor agnosticism isn't about avoiding commitment or using vendors superficially. It's about conscious coupling - knowing exactly where and why you depend on a vendor, and ensuring those touch points are manageable.

Use vendors deeply for their strengths, but couple loosely at the integration points. The best vendor relationship is one where you stay because you want to, not because you have to.

Remember: Every line of vendor-specific code is a future migration task. Make those lines count.