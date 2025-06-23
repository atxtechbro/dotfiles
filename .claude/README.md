# Claude Commands

Templates that get compiled into slash commands during setup.

## Commands

- `/project:close-issue <number>` - Close or fix an issue
- `/project:retro` - Run a retrospective

## How it works

1. Templates in `command-templates/` use `{{ INJECT:path }}` to pull from knowledge base
2. `utils/generate-claude-commands.sh` compiles them to `~/.claude/commands/`
3. Generated on each `source setup.sh`

That's it. Keep templates short, inject procedures dynamically.