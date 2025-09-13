# Close Issue CLI Tool

A provider-agnostic command-line tool for closing GitHub issues with AI assistance.

## Features

- **Provider Agnostic**: Works with multiple AI providers (Claude, Amazon Q, Cursor)
- **CLI Callable**: Can be used outside of interactive AI sessions
- **Automatic Worktree Setup**: Creates and manages git worktrees for each issue
- **Knowledge Base Integration**: Aggregates project knowledge for context
- **Backward Compatible**: Maintains existing `/close-issue` slash command functionality

## Installation

The `close-issue` script is located in the `bin/` directory. Make sure it's in your PATH:

```bash
export PATH="$PATH:$(pwd)/bin"
```

Or create a symlink to your local bin directory:

```bash
ln -s $(pwd)/bin/close-issue ~/bin/close-issue
```

## Usage

### Command Line

```bash
# Process an issue with default provider (Claude)
close-issue 123

# Explicitly specify a provider
close-issue 123 claude
close-issue 123 amazonq
close-issue 123 cursor

# Auto-detect available provider
close-issue 123 auto
```

### Environment Variables

- `AI_PROVIDER_PREFERENCE`: Set default AI provider preference

```bash
export AI_PROVIDER_PREFERENCE=claude
close-issue 123  # Will use Claude
```

### Within Claude Code

The `/close-issue` slash command now uses this CLI tool internally:

```
/close-issue 123
```

## How It Works

1. **Fetches Issue Details**: Uses GitHub CLI to get issue information
2. **Creates Worktree**: Sets up a git worktree with appropriate branch name
3. **Aggregates Knowledge**: Collects project knowledge base for context
4. **Generates Prompt**: Creates a comprehensive prompt for the AI provider
5. **Executes with Provider**: Runs the prompt through the selected AI tool

## Provider Support

| Provider | Status | Command |
|----------|--------|---------|
| Claude | ✅ Full Support | `claude -p` |
| Amazon Q | 🚧 Coming Soon | Manual prompt copy |
| Cursor | 🚧 Coming Soon | Manual prompt copy |

## Principles

- **systems-stewardship**: Single source of truth for issue closing logic
- **ai-provider-agnosticism**: Works across different AI tools
- **tracer-bullets**: Start simple, iterate and improve

## Testing

Use the test script to preview generated prompts without execution:

```bash
bin/test-close-issue 123
```

## Contributing

To add support for a new AI provider:

1. Add detection logic in the `detect_provider()` function
2. Add execution case in the provider switch statement
3. Update documentation

## Related Files

- `.claude/command-templates/close-issue.md`: Slash command template
- `knowledge/procedures/close-issue-procedure.md`: Core procedure documentation
- `.github/workflows/claude-implementation.yml`: GitHub Actions integration