# MCP Prompt Storage PoC

## Concept

Store reusable, version-controlled prompts that can be invoked through Amazon Q CLI via MCP servers.

## Structure

```
prompts/
├── git/                    # Git-related prompts
│   ├── commit-message.md   # Generate commit messages
│   ├── pr-description.md   # Generate PR descriptions
│   └── code-review.md      # Code review prompts
├── development/            # Development prompts
│   ├── debug-session.md    # Debugging assistance
│   ├── refactor.md         # Code refactoring
│   └── testing.md          # Test generation
└── documentation/          # Documentation prompts
    ├── readme.md           # README generation
    ├── api-docs.md         # API documentation
    └── troubleshooting.md  # Troubleshooting guides
```

## Usage Vision

With MCP integration, these prompts could be:

1. **Invoked by name**: `@commit-message` in Q chat
2. **Context-aware**: Automatically include relevant git status, file changes, etc.
3. **Parameterized**: Accept variables like file paths, commit types, etc.
4. **Version-controlled**: Track prompt evolution and share across team

## Implementation Approach

### Phase 1: File-based Storage
- Store prompts as markdown files with frontmatter metadata
- Use git MCP server to read prompt files
- Manual invocation through Q chat

### Phase 2: MCP Prompt Server
- Custom MCP server that serves prompts as resources
- Automatic context injection (git status, file contents, etc.)
- Template variable substitution

### Phase 3: Q CLI Integration
- Native `@prompt-name` syntax in Q chat
- Prompt discovery and autocomplete
- Prompt sharing and marketplace

## Benefits

- **Reusable**: Same prompts across projects and team members
- **Version-controlled**: Track what works, iterate on prompts
- **Context-aware**: Automatically include relevant project information
- **Shareable**: Team can build library of effective prompts
- **Discoverable**: Easy to find and use existing prompts
