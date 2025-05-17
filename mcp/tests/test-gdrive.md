# Google Drive MCP Server Test

This document provides test prompts for verifying the Google Drive MCP server integration.

## Prerequisites

1. Complete the setup by running:
   ```bash
   cd ~/ppv/pillars/dotfiles/mcp
   ./setup-gdrive-mcp.sh
   ```

2. Add your Google Drive API credentials to `~/.bash_secrets`:
   ```bash
   export GOOGLE_DRIVE_CLIENT_ID="your_client_id"
   export GOOGLE_DRIVE_CLIENT_SECRET="your_client_secret"
   export GOOGLE_DRIVE_REFRESH_TOKEN="your_refresh_token"
   ```

3. Restart your Amazon Q CLI or other MCP client.

## Test Prompts

### List Files

```
List my recent Google Drive files
```

### Search for Files

```
Search my Google Drive for documents containing "project plan"
```

### Create a Document

```
Create a new text file in my Google Drive called "notes.txt" with the content "These are test notes created via the MCP server"
```

### Get File Details

```
Get details about my most recent Google Drive spreadsheet
```

## Expected Behavior

- The MCP client should invoke the Google Drive MCP server
- Results should include your actual Google Drive files and folders
- Operations should modify your Google Drive as requested
- No errors should be displayed in the client output
