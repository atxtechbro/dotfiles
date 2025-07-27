# Command Templates

## ⚠️ IMPORTANT: Validation Goes in the Generator, NOT Here!

These templates should contain ONLY:
- Core business logic
- Agent instructions  
- Knowledge base references

**DO NOT** put validation here. See `utils/generate-commands.sh` for validation injection.

### Why?
- Validation in templates = token waste on every failure
- Validation in generator = zero tokens, fail fast

### Examples of What NOT to Put in Templates:
```markdown
❌ If no issue number was provided, respond with error...
❌ First check if the git repository is clean...
❌ Validate that the parameter is not empty...
```

### Instead, Add to generate-commands.sh:
```bash
case "$command_name" in
    your-command)
        cat >> "$output.tmp" << 'EOF'
# Your validation here
if [ -z "$PARAM" ]; then
    echo "Error: ..."
    exit 1
fi
EOF
        ;;
esac
```

See `knowledge/principles/generation-time-validation.md` for the full pattern.