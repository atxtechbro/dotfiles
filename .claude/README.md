# Claude Commands

Custom slash commands for Claude Code that leverage our established workflows and procedures.

## Available Commands

### `/project:close-issue <number>`
Intelligently closes GitHub issues - either with a simple closure or full implementation.

**Features:**
- Analyzes issue to determine if it needs implementation or just closure
- Quick close path for resolved/duplicate/invalid issues
- Full implementation path with worktree workflow for bugs/features
- Automatically creates PR that closes the issue when merged
- Includes post-implementation retrospective

**Decision Matrix:**
- Bug reports → Implementation path
- Approved features → Implementation path
- Questions/duplicates → Quick close with explanation
- Already implemented → Quick close with PR reference

### `/project:retro`
Conducts a collaborative retrospective on recent work.

**Features:**
- Reviews recent commits and changes
- Identifies what worked well
- Highlights areas for improvement
- Updates procedures based on learnings
- Focuses on systems improvement

## How Commands Work

1. **Templates** in `command-templates/` define the command structure
2. **Dynamic injection** pulls current procedures from the knowledge base
3. **Orchestration** happens via `utils/prompt_orchestrator.py`
4. **Generation** occurs during `source setup.sh`
5. **Output** goes to `commands/` directory

## Template Syntax

- `{{ ARGUMENTS }}` - The arguments passed to the command
- `{{ INJECT:path/to/file.md }}` - Injects content from knowledge base
- `{{ FUNCTION() }}` - Calls dynamic functions
- `{{ ENV:VAR }}` - Environment variables
- `{{ EXEC:command }}` - Command execution

## Adding New Commands

1. Create template in `.claude/command-templates/`
2. Use dynamic injection for procedures
3. Run `source setup.sh` to generate
4. Command available as `/project:command-name`

Principle: systems-stewardship