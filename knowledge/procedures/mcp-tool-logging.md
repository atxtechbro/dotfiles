# MCP Tool Logging Procedure

When adding, updating, or removing MCP server tool-level logging:

## Reference
→ [MCP README - Tool-Level Logging Guidelines](~/ppv/pillars/dotfiles/mcp/README.md#adding-tool-level-logging-to-mcp-servers)

## Steps
1. **Adding**: Follow logging_utils.py pattern, wrap call_tool(), update docs table
2. **Updating**: Modify existing logging calls, test with check-mcp-logs --tools  
3. **Removing**: Clean up logging calls, update docs table to "No"

## Test
- Verify logs in ~/mcp-tool-calls.log
- Check both success/error scenarios
- Confirm check-mcp-logs displays properly

Reference implementation: atxtechbro-git-mcp-server
