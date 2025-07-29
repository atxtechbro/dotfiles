# Coding Conventions

Small but important conventions learned through experience. These prevent common errors and ensure consistency.

## File Operations

### Always Use Absolute Paths
**Rule**: Use `/full/path` or `~/path` - never relative paths like `./file`

This prevents path resolution errors, especially with tools like fs_write.

**Validation from Anthropic**: "We found that the model would make mistakes with tools using relative filepaths after the agent had moved out of the root directory. To fix this, we changed the tool to always require absolute filepaths—and we found that the model used this method flawlessly." ([Source](https://www.anthropic.com/engineering/building-effective-agents))

## Python Development

### Use UV for Package Management
Use `uv` instead of `pip` for all Python packaging operations:
- `uv pip install package` instead of `pip install package`
- Modern, fast, and consistent with current best practices

## Configuration

### Prefer Data Over Code
When configuring tools, prefer declarative JSON/YAML over imperative scripts. See [configuration-as-code](configuration-as-code.md) for detailed patterns.

## Git Operations

### Use MCP Git Tools
Always use `mcp__git__*` tools instead of bash git commands:
- Better error handling
- Consistent interface
- Proper path resolution

## These Are Living Conventions

This list grows as we learn. When you discover a pattern that prevents errors or improves consistency, add it here with a brief explanation of why it matters.