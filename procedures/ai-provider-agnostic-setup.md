# AI Provider Agnostic Setup Procedure

## Overview
This procedure enables any AI coding assistant to use the same context rules by symlinking provider-specific files to a central `AI-RULES.md`.

## Core Pattern
1. **Single source of truth**: `AI-RULES.md` contains all repository context
2. **Provider symlinks**: Each provider's expected file symlinks to `AI-RULES.md`
3. **Zero maintenance**: Update one file, all providers see changes

## Setup Steps

### 1. Create Central Rules File
```bash
# Copy existing provider file to AI-RULES.md (if starting from existing)
cp AmazonQ.md AI-RULES.md

# Or create new AI-RULES.md from scratch
```

### 2. Replace Provider File with Symlink
```bash
# Remove original provider file
rm [PROVIDER_FILE]

# Create symlink to central rules
ln -s AI-RULES.md [PROVIDER_FILE]
```

### 3. Verify Symlink
```bash
ls -la [PROVIDER_FILE]
# Should show: [PROVIDER_FILE] -> AI-RULES.md
```

## Known Provider Files
- **Amazon Q CLI**: `AmazonQ.md` ✅ (implemented)
- **Claude Desktop**: `CLAUDE.md` (needs investigation)
- **Claude Code**: Unknown file (needs investigation)
- **Cursor**: `.cursorrules` (needs confirmation)
- **OpenAI Codex**: Unknown file (needs investigation)

## Testing
After creating symlink, test that the AI provider still reads context correctly:
1. Start AI provider session
2. Verify it references content from AI-RULES.md
3. Make test edit to AI-RULES.md
4. Confirm provider sees the change

## Benefits
- **Provider agnostic**: Switch between AI tools seamlessly
- **Single maintenance point**: Edit one file, update all providers
- **Future-proof**: Easy to add new AI providers
- **No vendor lock-in**: Avoid bias toward any specific AI tool

## Troubleshooting
- **Symlink not working**: Check file permissions and path
- **Provider not reading**: Verify provider's expected filename
- **Multiple symlinks**: This is normal and supported by filesystems
