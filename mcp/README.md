# MCP Server Development

This directory contains documentation and tools for working with Model Context Protocol (MCP) servers.

## AWS Documentation MCP Server

The AWS Documentation MCP server provides tools for accessing AWS documentation directly from Amazon Q.

### Current Status

The AWS Documentation MCP server is working correctly and provides access to AWS documentation.

### Testing

You can test the AWS Documentation MCP server by running:

```bash
cd ~/ppv/pillars/dotfiles/mcp/servers/aws-docs
./run-aws-docs-mcp.sh
```

In another terminal, you can then use Amazon Q to access AWS documentation:

```bash
q chat
```

And ask questions about AWS services and documentation.

### Development Approach

We're following a tracer bullet development approach:

1. Add extensive logging at key points in the code
2. Build from source to incorporate logging changes
3. Run tests to gather diagnostic information
4. Fix one issue at a time, committing early and often
5. Repeat until the basic functionality works
