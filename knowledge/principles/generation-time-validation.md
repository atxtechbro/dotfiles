# Generation-Time Validation Pattern

The principle that validation and environment setup should happen at code generation time rather than runtime, preventing waste before it occurs.

## The Pattern

When you have a code generator (like `generate-commands.sh`), it becomes a **policy enforcement point** where you can:
1. Inject validation before runtime
2. Setup/teardown environment requirements
3. Document constraints in executable form
4. Fail fast at zero token cost

## Architecture Decision

**When to apply**: Any time you have generated code that will be executed later
**Where to apply**: In the generator, not the template
**How to recognize**: Look for patterns like "every time X runs, we check Y"

## Implementation Strategy

```bash
# In your generator (e.g., generate-commands.sh)
case "$command_name" in
    pattern-name)
        # 1. Environment validation/setup
        # 2. Parameter validation
        # 3. State assertions
        # 4. Cleanup/teardown hooks
        ;;
esac
```

## Benefits

- **Zero runtime cost**: Validation happens once at generation
- **Fail fast**: Errors surface immediately, not after token consumption
- **Self-documenting**: The generator becomes living documentation of requirements
- **DRY principle**: Validation logic lives in one place
- **Bottleneck prevention**: Constraints handled before they impact throughput

## Relationship to Theory of Constraints

This pattern directly addresses Goldratt's Theory of Constraints:
- **Identify**: The constraint is runtime validation consuming tokens/cycles
- **Exploit**: Move validation to generation time
- **Subordinate**: Templates become simpler, focused on core logic
- **Elevate**: The generator becomes a systematic constraint preventer

## Examples in the Wild

- **Compilers**: Type checking at compile time vs runtime
- **Build tools**: Maven/Gradle validating dependencies before compilation
- **Infrastructure as Code**: Terraform plan vs apply
- **Our implementation**: Shell validation in generate-commands.sh

## Anti-patterns to Avoid

- **Template complexity**: Don't put validation in templates
- **Runtime discovery**: Don't check environment state during execution
- **Defensive programming**: Don't add "just in case" checks in generated code

## Architectural Rule

> **"If it can be validated at generation time, it must be validated at generation time"**

This becomes a forcing function - when writing templates, always ask:
1. What assumptions am I making?
2. Can I validate these when generating?
3. What environment setup is repeatedly needed?

## Related Principles

- **Subtraction Creates Value**: Remove runtime validation from templates
- **Systems Stewardship**: The generator documents all system requirements
- **OSE**: Elevate validation to the orchestration layer
- **Write It Down**: Constraints become code, not tribal knowledge