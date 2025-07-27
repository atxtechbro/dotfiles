# Command Generation Checklist

A procedure for implementing generation-time validation when creating or modifying slash commands.

## When Creating a New Command

### 1. Identify Requirements
Before writing the template, list:
- Required parameters (e.g., ISSUE_NUMBER)
- Environment prerequisites (e.g., clean git state)
- Common failure modes (e.g., dirty branches)
- Cleanup needs (e.g., stash changes)

### 2. Implement in Generator First
In `generate-commands.sh`, add a case for your command:

```bash
case "$command_name" in
    your-command)
        cat >> "$output.tmp" << 'EOF'
# Parameter validation
if [ -z "$REQUIRED_PARAM" ]; then
    echo "Error: ..."
    exit 1
fi

# Environment validation
if ! git diff --quiet; then
    echo "Error: Uncommitted changes detected"
    exit 1
fi

# Setup/teardown
trap 'cleanup_function' EXIT
EOF
        ;;
esac
```

### 3. Keep Templates Simple
Templates should only contain:
- Core business logic
- Agent instructions
- Knowledge base references

NOT:
- Parameter validation
- Environment checks
- Defensive programming

## When Modifying Existing Commands

1. **Identify repeated patterns**: "Agent always has to check X"
2. **Move to generator**: Extract validation to generate-commands.sh
3. **Simplify template**: Remove now-redundant checks
4. **Document in PR**: Reference generation-time-validation principle

## Red Flags to Watch For

- Templates with bash conditionals checking parameters
- Agent instructions about validating environment
- Repeated "first check if..." instructions
- Token waste on validation failures

## Example Migration

**Before** (in template):
```markdown
First, check if ISSUE_NUMBER is provided...
If not provided, respond with error...
```

**After** (in generator):
```bash
if [ -z "$ISSUE_NUMBER" ]; then
    echo "Error: Issue number required"
    exit 1
fi
```

## The Litmus Test

Ask yourself:
> "Will this validation ever produce different results at runtime than at generation time?"

If no → Move it to the generator
If yes → It's truly runtime validation (rare)

This procedure ensures the Generation-Time Validation pattern becomes the default choice, not an afterthought.