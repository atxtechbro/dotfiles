# AI Provider Agnostic Setup Procedure

## Overview
This procedure enables any AI coding assistant to use the same context rules by symlinking provider-specific files to a central `AI-RULES.md`.

## Core Pattern
1. **Single source of truth**: `AI-RULES.md` contains all repository context
2. **Provider symlinks**: Each provider's expected file symlinks to `AI-RULES.md`
3. **Zero maintenance**: Update one file, all providers see changes
4. **Git tracked**: Symlinks are committed to version control

## Adding a New AI Provider

### Step 1: Research the Provider's Context File
**CRITICAL**: Only add providers where you've confirmed the exact context file name.

Research methods:
- Check official documentation
- Search GitHub repos using that provider
- Test with a simple context file to confirm it's read
- Ask in provider's community forums

### Step 2: Create and Test the Symlink
```bash
# Navigate to dotfiles root
cd ~/ppv/pillars/dotfiles

# Create symlink (ONLY after confirming filename)
ln -s AI-RULES.md [CONFIRMED_PROVIDER_FILE]

# Verify symlink creation
ls -la [CONFIRMED_PROVIDER_FILE]
# Should show: [CONFIRMED_PROVIDER_FILE] -> AI-RULES.md
```

### Step 3: Test Provider Reads Context
**BEFORE COMMITTING**: Test that the provider actually reads the symlinked file:
1. Start AI provider session
2. Verify it references content from AI-RULES.md
3. Make test edit to AI-RULES.md
4. Confirm provider sees the change

### Step 4: Commit to Git
```bash
# Only commit after successful testing
git add [CONFIRMED_PROVIDER_FILE]
git commit -m "feat: add [Provider] symlink to AI-RULES.md"
git push
```

## Currently Implemented Providers
- **Amazon Q CLI**: `AmazonQ.md` ✅ (confirmed working)
- **Claude Desktop**: `CLAUDE.md` ✅ (confirmed working)

## Investigation Needed
- **Claude Code**: Unknown context file mechanism
- **Cursor**: Likely `.cursorrules` but needs confirmation
- **OpenAI Codex**: Unknown context file mechanism
- **GitHub Copilot**: Uses workspace context, may not have specific file

## Benefits
- **Provider agnostic**: Switch between AI tools seamlessly
- **Single maintenance point**: Edit one file, update all providers
- **Version controlled**: Symlinks tracked in git
- **No setup scripts**: Works immediately after git clone
- **Future-proof**: Easy to add confirmed providers

## Anti-Patterns to Avoid
- ❌ **Don't guess filenames** - always confirm first
- ❌ **Don't add setup script complexity** - commit symlinks directly
- ❌ **Don't commit untested symlinks** - test provider reads context first
- ❌ **Don't assume similar providers use same files** - each needs research

## Troubleshooting
- **Symlink not working**: Check file permissions and path
- **Provider not reading**: Verify provider's expected filename through research
- **Git not tracking symlink**: Ensure you used `git add` on the symlink file
