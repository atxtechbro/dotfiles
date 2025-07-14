# Provider-Agnostic Commands

This directory contains command templates that work across multiple AI providers (Claude, Amazon Q, etc.) without duplication.

## Structure

```
commands/
├── README.md          # This file
└── templates/         # Provider-agnostic command templates
    ├── close-issue.md
    ├── retro.md
    └── ...
```

## How It Works

1. **Templates live here**: All command templates are stored in `commands/templates/`
2. **Providers symlink**: Each AI provider creates symlinks to these templates:
   - Claude: `.claude/command-templates` → `commands/templates`
   - Amazon Q: `.amazonq/commands` → `commands/templates` (if/when supported)
3. **Single source of truth**: Edit files in `commands/templates/`, changes apply everywhere

## Important Notes

- **Always edit the actual template files** in `commands/templates/`
- **Never edit via symlinks** (e.g., `.claude/command-templates/`)
- Symlinks are created automatically by `setup.sh` and gitignored to avoid content duplication

## Adding New Commands

1. Create your template in `commands/templates/your-command.md`
2. Use the `{{ INJECT:path/to/file.md }}` syntax for dynamic content
3. Run `utils/generate-claude-commands.sh` to generate provider-specific versions

## Why This Architecture?

- **DRY Principle**: Write once, use everywhere
- **Provider flexibility**: Easy to add new AI providers
- **Consistent experience**: Same commands work across all tools
- **Maintainability**: Single place to update commands

This approach follows our Versioning Mindset - evolve the system rather than duplicate it.