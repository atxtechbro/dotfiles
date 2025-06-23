# Prompt Orchestration System

A unified system for composing prompts from templates, used across dotfiles and other projects.

## Overview

The prompt orchestration system transforms template files with placeholders into fully composed prompts by injecting content from various sources. This follows the Template Method Pattern with Strategy Pattern for resolution.

## Core Tool: `utils/prompt_orchestrator.py`

### Features

1. **Variable Substitution**: `{{ VARIABLE_NAME }}`
2. **File Injection**: `{{ INJECT:path/to/file.md }}`
3. **Dynamic Functions**: `{{ FUNCTION_NAME() }}`
4. **Environment Variables**: `{{ ENV:VARIABLE }}`
5. **Command Execution**: `{{ EXEC:command }}`
6. **JSON Data Extraction**: Automatic flattening and mapping

### Usage

```bash
# Basic variable substitution
prompt_orchestrator.py template.md -v NAME=value

# With output file
prompt_orchestrator.py template.md -o output.md

# Multiple variables
prompt_orchestrator.py template.md -v ISSUE=123 -v REPO=dotfiles

# With JSON data sources
prompt_orchestrator.py template.md -j data.json

# Custom knowledge base
prompt_orchestrator.py template.md -k ~/my-knowledge

# Full example
prompt_orchestrator.py template.md \
  -v ISSUE_NUMBER=123 \
  -j config.json \
  -k ~/ppv/pillars/dotfiles/knowledge \
  -o processed.md
```

## Integration Examples

### Claude Commands

Located in `.claude/command-templates/`, processed by `generate-claude-commands.sh`:

```markdown
Fix GitHub issue #{{ ARGUMENTS }}

## Principles
{{ INJECT:principles/do-dont-explain.md }}

## Workflow
{{ INJECT:procedures/worktree-workflow.md }}
```

### Lifehacking Integration

Lifehacking uses a wrapper that imports the dotfiles orchestrator and adds domain-specific functions:

```python
# lifehacking/scripts/prompt_orchestrator.py
from prompt_orchestrator import PromptOrchestrator

# Add custom functions
orchestrator.add_custom_function('DAYS_OUT', calculate_days)
orchestrator.add_custom_function('ATHLETE_AGE', calculate_age)
```

## Architecture

### Design Patterns

1. **Template Method Pattern**: Core algorithm for processing templates
2. **Strategy Pattern**: Different resolvers for different placeholder types
3. **Chain of Responsibility**: Resolvers tried in sequence

### Resolver Types

1. **VariableResolver**: Simple variable substitution
2. **FileInjectionResolver**: Inject file contents
3. **FunctionResolver**: Execute Python functions
4. **EnvironmentResolver**: Read environment variables
5. **CommandResolver**: Execute shell commands

### Extensibility

Add new resolver types by:
1. Inherit from `PlaceholderResolver`
2. Implement `can_resolve()` and `resolve()`
3. Add to orchestrator's resolver list

## Best Practices

1. **Use spaces in placeholders**: `{{ VARIABLE }}` not `{{VARIABLE}}`
2. **Keep templates focused**: Structure over content
3. **Store reusable content**: In knowledge base for injection
4. **Version templates**: Track changes over time
5. **Document requirements**: Clear placeholder documentation

## Benefits

1. **DRY Principle**: Define once, use everywhere
2. **Single Source of Truth**: Knowledge base maintains content
3. **Dynamic Compilation**: Always current information
4. **Cross-Project Sharing**: Unified tool for all projects
5. **Extensible Design**: Easy to add new features

## Migration from Bash

The Python implementation replaces the bash `prompt-compile` tool with:
- Better error handling
- More resolver types
- Cleaner architecture
- Cross-platform compatibility
- Easier maintenance

Old: `prompt-compile -o output.md template.md`
New: `prompt_orchestrator.py template.md -o output.md`

Principle: systems-stewardship
Principle: versioning-mindset