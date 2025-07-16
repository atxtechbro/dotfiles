# Claude Non-Interactive Execution

## Constraint Type
Physical - Architectural limitation of the Claude Code CLI

## Description
Claude Code operates as the interactive session itself and cannot spawn nested interactive processes. This is a fundamental architectural constraint that cannot be overcome through configuration or workarounds.

## Impact on Five Focusing Steps
1. **Identify**: This is the constraint when commands hang waiting for input
2. **Exploit**: Use non-interactive flags for all commands
3. **Subordinate**: All procedures must account for this limitation
4. **Elevate**: Not possible - this is a physical constraint
5. **Repeat**: N/A - constraint cannot be broken

## Examples
- ❌ `claude setup-token` - Will hang indefinitely
- ✅ `claude -p setup-token` - Bypasses interactive mode
- ❌ `git commit` - Waits for editor
- ✅ `git commit -m "message"` - Provides input upfront

## Related Constraints
- Context window limits (another physical constraint)
- MCP tool execution model (physical)