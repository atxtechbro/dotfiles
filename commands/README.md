# Commands Directory

This directory contains command files for the Claude Code plugin.

## ⚠️ Important: These are Generated Files

**DO NOT EDIT FILES DIRECTLY IN THIS DIRECTORY**

The `.md` files in this directory (except test files) are automatically generated from the source procedures in `knowledge/procedures/`.

### Source of Truth
- **Edit source files in**: `knowledge/procedures/`
- **Run sync script**: `./scripts/sync-plugin-commands.sh`
- **Files are copied here**: `commands/`

### Why Regular Files?

Claude Code's plugin system doesn't follow symlinks when discovering command files. Therefore, we maintain:
1. Single source of truth in `knowledge/procedures/`
2. Synced copies here for the plugin to discover

### Test Files

The following files are test cases and are maintained directly in this directory:
- `test-nonsymlink.md` - Test case for regular file command discovery
- `close-issue-minimal.md` - Minimal test version of close-issue command

### Syncing Commands

To update commands after modifying procedures:

```bash
./scripts/sync-plugin-commands.sh
```

This script will:
- Remove old symlinks
- Copy procedures with valid frontmatter
- Transform filenames (removes `-procedure` suffix)
- Preserve test files

### File Naming Convention

| Source File | Synced As |
|------------|-----------|
| `close-issue-procedure.md` | `close-issue.md` |
| `retro-procedure.md` | `retro.md` |
| `issue-creation-procedure.md` | `issue-creation.md` |

Files without `-procedure` suffix are copied as-is.