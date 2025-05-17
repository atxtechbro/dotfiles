# Slack MCP Server Test

This document provides test prompts for verifying the Slack MCP server integration.

## Prerequisites

1. Complete the setup by running:
   ```bash
   cd ~/ppv/pillars/dotfiles/mcp
   ./setup-slack-mcp.sh
   ```

2. Add your Slack bot token to `~/.bash_secrets`:
   ```bash
   export SLACK_BOT_TOKEN="xoxb-your-token"
   ```

3. Restart your Amazon Q CLI or other MCP client.

## Test Prompts

### List Channels

```
List all the Slack channels I have access to
```

### List Users

```
Show me a list of users in my Slack workspace
```

### Send a Message

```
Send a message to the #general Slack channel saying "Hello from the MCP server test!"
```

### Get Recent Messages

```
Show me the 5 most recent messages from the #random Slack channel
```

### Search Messages

```
Search Slack for messages containing "meeting notes"
```

## Expected Behavior

- The MCP client should invoke the Slack MCP server
- Results should include your actual Slack channels, users, and messages
- Messages should be sent to your Slack workspace as requested
- No errors should be displayed in the client output
