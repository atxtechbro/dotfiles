# Non-Interactive Execution Only

**Fundamental truth**: If you (Claude) are reading this, you are BY DEFINITION already in an interactive session. Therefore, you literally CANNOT provide interactive input to any command.

## Core Principle

Interactive commands violate **OSE (Outside and Slightly Elevated)** because:
- They pull you down from orchestration level to implementation details
- They create blocking states that break automation flow
- They assume a human is present to provide input

## Universal Rule

**NEVER** run commands that might expect interactive input. **ALWAYS** find the non-interactive alternative.

## Common Patterns

### Command Invocation
```bash
# ALWAYS use non-interactive flags
claude -p <command>          # Never 'claude' alone
```

### Git Operations
```bash
git commit -m "message"      # Never 'git commit' (opens editor)
git rebase main              # Never 'git rebase -i' (interactive)
git add .                    # Never 'git add -p' (patch mode)
git merge --no-edit          # Never risk merge message editor
```

### Package Managers
```bash
npm install --yes            # Never risk npm prompts
npm init -y                  # Never interactive init
apt-get install -y package   # Never risk apt confirmations
pip install --yes package    # Never risk pip prompts
```

### File Operations
```bash
rm -f file                   # Never 'rm' alone (might prompt)
cp -f source dest            # Force to avoid prompts
mv -f old new                # Force to avoid confirmations
```

### System Commands
```bash
sudo command                 # Only if passwordless sudo configured
ssh -o BatchMode=yes host    # Never risk password/key prompts
```

## Red Flags

Commands that might block on interactive input:
- Anything that opens an editor (vim, nano, less)
- Confirmation prompts (y/n, yes/no)
- Password/authentication prompts
- Menu selections or choices
- Pagers that wait for 'q' to exit

## Testing Safely

When testing any command:
1. Check if it has a `--help` flag first
2. Look for non-interactive flags (`-y`, `--yes`, `--force`, `-n`, `--no-input`)
3. Use timeout if unsure: `timeout 5s command`

## Why This Matters

- **Throughput**: Eliminates entire class of hanging failures
- **OSE**: Maintains elevated orchestration perspective
- **Automation**: Enables true autonomous operation

Remember: You're not being careful, you're recognizing reality - you ARE the interactive session.