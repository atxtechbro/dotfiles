# Prompt Orchestration

Transforms template files with placeholders into composed prompts.

## Template Syntax

```
{{ VARIABLE }}           - Variable substitution
{{ INJECT:path/to/file }} - File injection from knowledge base
{{ FUNCTION() }}         - Function call
{{ ENV:VARIABLE }}       - Environment variable
{{ EXEC:command }}       - Command execution
```

## Usage

```bash
# Basic usage
./utils/prompt_orchestrator.py template.md -v NAME=value -o output.md

# With JSON data
./utils/prompt_orchestrator.py template.md -j data.json

# With knowledge base
./utils/prompt_orchestrator.py template.md -k /path/to/knowledge
```

## Claude Commands

1. Templates in `.claude/command-templates/`
2. Run `source setup.sh` to generate
3. Commands available in Claude Code

## Cross-Repo Usage

```python
# In other repos like lifehacking
sys.path.insert(0, str(Path.home() / 'ppv/pillars/dotfiles/utils'))
from prompt_orchestrator import PromptOrchestrator
```

That's it. Define once, use everywhere.