# Claude Code Debugging Procedure

**Rule: Always use `claude-debug` when debugging Claude Code issues.**

## Debug Environment Setup

Use `claude-debug` alias for enhanced debugging:
```bash
# Enables DEBUG=1 and non-interactive mode (-p)
claude-debug "your prompt here"
```

## Common Issues

### Tool Name Length Validation Error

**Error**: `API Error: 400 tools.93.custom.name: String should have at most 64 characters`

**Root Cause**: Claude Code enforces a 64-character limit on MCP tool names, while Claude Desktop does not.

**Reference**: [GitHub Issue #2445](https://github.com/anthropics/claude-code/issues/2445)

**Debugging Steps**:

1. **Identify the problematic tool**:
   ```bash
   # Run with debug to see tool loading
   claude-debug "list tools" 2>&1 | grep -E "(tool|name|error)"
   ```

2. **Check MCP server tool names**:
   ```bash
   # Test each MCP server individually
   for server in git github-read github-write gitlab brave-search filesystem gdrive; do
     echo "Testing $server..."
     echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | \
       ~/ppv/pillars/dotfiles/mcp/wrappers/${server}-mcp-wrapper.sh 2>/dev/null | \
       jq -r '.result.tools[]?.name // empty' | \
       awk 'length > 64 {print "LONG: " $0 " (" length($0) " chars)"}'
   done
   ```

3. **Check work-specific servers** (if `WORK_MACHINE=true`):
   ```bash
   # Test Atlassian and other work servers
   for server in atlassian; do
     echo "Testing work server: $server..."
     echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "debug", "version": "1.0.0"}}}
{"jsonrpc": "2.0", "method": "notifications/initialized"}
{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}' | \
       ~/ppv/pillars/dotfiles/mcp/${server}-mcp-wrapper.sh 2>/dev/null | \
       tail -1 | jq -r '.result.tools[].name' | \
       awk 'length > 64 {print "LONG: " $0 " (" length($0) " chars)"}'
   done
   ```

4. **Fix long tool names**:
   - Edit the MCP server implementation to shorten tool names
   - Use abbreviations or remove redundant prefixes
   - Ensure names are descriptive but under 64 characters

### Bedrock Integration Issues

**Symptoms**: Work machine detection but API errors

**Debug Steps**:
1. Check AWS credentials: `aws sts get-caller-identity`
2. Verify Bedrock permissions
3. Test with `claude-debug` to see detailed error messages

## Environment Variables

- `DEBUG=1` - Enables verbose Claude Code logging
- `WORK_MACHINE=true` - Enables work-specific MCP servers
- `FASTMCP_LOG_LEVEL=ERROR` - Controls MCP server logging

## Systematic Debugging Approach

1. **Isolate the problem**: Use `claude-debug` with minimal prompts
2. **Check tool loading**: Look for tool name length violations
3. **Test MCP servers individually**: Use protocol-level testing
4. **Document findings**: Update this procedure with new discoveries

## Force Multiplier Investment

Time spent on debugging infrastructure pays exponential dividends:
- Faster issue resolution in the future
- Systematic approach prevents repeated investigation
- Documentation enables team knowledge sharing
- Debug aliases reduce cognitive overhead

**Principle**: Systems stewardship - invest in debugging capabilities to make all future debugging faster.
