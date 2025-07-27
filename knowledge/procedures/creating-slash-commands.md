# Creating Slash Commands

The **ONLY** way to create new slash commands. This procedure enforces the Generation-Time Validation pattern by default.

## The One True Path

```bash
./utils/create-command-template.sh <command-name> [PARAM1] [PARAM2] ...
```

This tool:
1. Creates a template with proper structure
2. Adds validation stubs to generate-commands.sh
3. Makes validation-in-generator the obvious next step

## Example

```bash
# Create a command that needs an issue number and action
./utils/create-command-template.sh update-issue ISSUE_NUMBER ACTION

# Output:
✅ Created template: commands/templates/update-issue.md
✅ Added validation stub to generate-commands.sh

Next steps:
1. Edit commands/templates/update-issue.md to add your command logic
2. Implement validation in generate-commands.sh (search for 'update-issue')
3. Run ./utils/generate-commands.sh to test
```

## Why This Way?

- **Pit of success**: The tool creates the right structure automatically
- **Validation stubs**: Generator already has TODO comments for your validations
- **No heroics needed**: Just follow the breadcrumbs

## Anti-patterns This Prevents

❌ Manually creating template files
❌ Forgetting to add validation to generator
❌ Putting validation in templates
❌ Discovering the pattern only after deep retro

## The Workflow

1. **Create**: Use the tool (only way to start)
2. **Edit template**: Add core logic only
3. **Edit generator**: Implement the pre-created validation stubs
4. **Test**: Run generate-commands.sh
5. **Verify**: Run check-template-validation.sh

## Red Flags

If you find yourself:
- Creating `.md` files in `commands/templates/` manually → STOP
- Writing "if empty then error" in templates → STOP
- Not sure where validation goes → Use the tool

## Enforcement

- Pre-commit hook blocks validation in templates
- Validation checker finds anti-patterns
- Only one blessed path forward

Remember: **There is no other way.** Use `create-command-template.sh` or don't create commands.