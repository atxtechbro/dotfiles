# Worktree Development Guide

This guide explains how to use git worktrees for parallel development in the dotfiles repository.

## Why Use Worktrees?

Git worktrees allow you to have multiple branches checked out simultaneously in different directories. This is perfect for:
- Working on multiple features in parallel
- Testing changes in isolation
- Keeping your main repo clean while experimenting

## Creating a Worktree

```bash
# From the main dotfiles directory
cd ~/ppv/pillars/dotfiles

# Create a new worktree with a new branch
git worktree add -b feature/my-feature worktrees/feature/my-feature

# Or use an existing branch
git worktree add worktrees/fix/existing-fix fix/existing-fix
```

## Setting Up the Worktree Environment

**IMPORTANT**: Each worktree needs its own environment setup to work properly.

```bash
# Navigate to your worktree
cd ~/ppv/pillars/dotfiles/worktrees/feature/my-feature

# Source setup.sh from the worktree directory
source setup.sh
```

This will:
- Set `DOT_DEN` to the worktree directory
- Add the worktree's MCP directories to PATH
- Install all MCP server dependencies locally in the worktree
- Build/copy all necessary binaries to the worktree

## MCP Servers in Worktrees

The setup process ensures all MCP servers work correctly in worktrees by:

1. **Installing npm packages**: MCP dependencies installed in `worktree/node_modules`
2. **Generating configs**: MCP configurations are generated for the worktree path

## Working with MCP in Worktrees

After setup, MCP servers configured in Claude desktop settings should work normally.

## Common Issues and Solutions

### Issue: MCP servers fail with "binary not found"
**Solution**: Run `source setup.sh` from the worktree directory to build/install dependencies

### Issue: npm packages not found
**Solution**: The setup script should install them. If not, run:
```bash
npm install
```

## Cleaning Up Worktrees

When you're done with a worktree:

```bash
# From anywhere
git worktree remove ~/ppv/pillars/dotfiles/worktrees/feature/my-feature

# Or force remove if there are uncommitted changes
git worktree remove -f ~/ppv/pillars/dotfiles/worktrees/feature/my-feature
```

## Best Practices

1. **Always source setup.sh** from the worktree directory after creating it
2. **Keep worktrees organized** in the `worktrees/` subdirectory
3. **Name worktrees after their branch** for easy identification
4. **Clean up worktrees** when done to save disk space
5. **Don't share binaries** between worktrees - each should be self-contained

## Technical Details

The setup works because:
- `DOT_DEN` is set to the directory where setup.sh is sourced from
- All scripts use `$DOT_DEN` or relative paths from their location
- MCP wrapper scripts resolve paths relative to their own location
- Each worktree gets its own complete set of dependencies

This follows the "Spilled Coffee Principle" - if your laptop dies, you can recreate any worktree by just running `source setup.sh` from it.