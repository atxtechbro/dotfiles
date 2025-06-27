# Slash Command Generation

How slash commands actually work (note to future self who will forget):

1. **Templates** in `.claude/command-templates/` - the source files
2. **Generator** (`utils/generate-claude-commands.sh`) - runs during setup.sh
3. **Output** in `~/.claude/commands/` - what Claude Code actually reads

When you type `/close-issue 123`:
- Claude reads the GENERATED file (not the template)
- Any logging we want has to be injected during generation
- That's why we modify the generator, not the runtime

Think of it like:
- Templates = .java files
- Generator = javac compiler  
- Commands = .class files

The analytics logging gets baked in at "compile time" by the generator.