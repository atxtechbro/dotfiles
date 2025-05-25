# Google Drive MCP Server Test

This document provides instructions for testing the Google Drive MCP server integration.

## Prerequisites

Before testing, ensure you have:

1. Completed the Google Drive MCP setup by running `./setup-gdrive-mcp.sh`
2. Successfully authenticated with Google Drive during the setup process
3. Confirmed that the token file exists at `~/tmp/gdrive-oath/token.json`

## Testing with Amazon Q

1. Start Amazon Q:
   ```bash
   q chat
   ```

2. Test searching for files in Google Drive:
   ```
   Search for PDF files in my Google Drive
   ```

3. Expected behavior:
   - Amazon Q should use the Google Drive MCP server to search for files
   - Results should include file names and types matching your query

## Manual Testing

You can also test the Google Drive MCP server directly:

1. Test the wrapper script:
   ```bash
   ./gdrive-mcp-wrapper.sh
   ```
   
   This should start the server without errors.

2. In another terminal, you can send a test query:
   ```bash
   echo '{"jsonrpc":"2.0","id":1,"method":"callTool","params":{"name":"search","arguments":{"query":"test"}}}' | nc -N localhost 3000
   ```

## Troubleshooting

If the Google Drive MCP server is not working:

1. Check that the token file exists:
   ```bash
   ls -la ~/tmp/gdrive-oath/token.json
   ```

2. Verify Docker is running (needed for authentication):
   ```bash
   docker ps
   ```

3. Try re-running the setup script:
   ```bash
   ./setup-gdrive-mcp.sh
   ```

4. If authentication fails, you may need to:
   - Delete the existing token file: `rm ~/tmp/gdrive-oath/token.json`
   - Ensure your credentials.json is valid
   - Run the setup script again

5. Check for TypeScript installation:
   ```bash
   tsc --version
   ```
   
   If not installed, run: `npm install -g typescript`

## Expected Output

When working correctly, the Google Drive MCP server should return results like:

```
Found 3 files:
Document.pdf (application/pdf)
Spreadsheet.xlsx (application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)
Presentation.pptx (application/vnd.openxmlformats-officedocument.presentationml.presentation)
```

The actual results will depend on the files in your Google Drive account.
