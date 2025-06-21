# AI Provider Agnostic Setup

## Steps
1. **Research**: Confirm provider's exact context filename
2. **Create symlink**: `ln -s AI-RULES.md CLAUDE.md`
3. **Test**: Verify provider reads the symlinked context
4. **Commit**: `git add CLAUDE.md && git commit -m "feat: add Claude symlink"`

## Example: Adding Claude
```bash
cd ~/ppv/pillars/dotfiles
ln -s AI-RULES.md CLAUDE.md
# Test Claude reads context
git add CLAUDE.md
git commit -m "feat: add Claude symlink to AI-RULES.md"
```

Single source of truth: `AI-RULES.md`. All providers symlink to it.
