# GitHub MCP Server

An in-house GitHub MCP server that provides comprehensive GitHub API integration through the Model Context Protocol.

## Features

- Full GitHub API v3 and GraphQL v4 support
- Organized toolsets for different GitHub features
- Read-only mode for safe operations
- Dynamic toolset discovery
- **Batch execution support for chaining multiple GitHub operations**

## Available Toolsets

| Toolset | Description | Tools |
|---------|-------------|-------|
| `context` | User and authentication context | `get_me` |
| `repos` | Repository operations | `search_repositories`, `get_file_contents`, `list_commits`, `create_repository`, `fork_repository`, etc. |
| `issues` | Issue management | `get_issue`, `search_issues`, `create_issue`, `update_issue`, `add_issue_comment` |
| `pull_requests` | Pull request operations | `get_pull_request`, `create_pull_request`, `merge_pull_request`, `create_pull_request_review`, etc. |
| `actions` | GitHub Actions workflows | `list_workflows`, `run_workflow`, `get_workflow_run`, `rerun_failed_jobs`, etc. |
| `notifications` | Notification management | `list_notifications`, `dismiss_notification`, `mark_all_notifications_read` |
| `batch` | Batch execution | `github_batch` - Execute multiple GitHub operations in sequence |

## Batch Execution

The `github_batch` tool allows you to chain multiple GitHub operations together, reducing the number of AI-agent-human feedback cycles and enabling complex workflows in a single call.

### Usage

```json
{
  "tool": "github_batch",
  "args": {
    "commands": [
      {
        "tool": "get_issue",
        "args": {
          "owner": "atxtechbro",
          "repo": "dotfiles",
          "issue_number": 123
        }
      },
      {
        "tool": "add_issue_comment",
        "args": {
          "owner": "atxtechbro",
          "repo": "dotfiles",
          "issue_number": 123,
          "body": "I've reviewed this issue."
        }
      },
      {
        "tool": "update_issue",
        "args": {
          "owner": "atxtechbro",
          "repo": "dotfiles",
          "issue_number": 123,
          "state": "closed"
        }
      }
    ]
  }
}
```

### Benefits

- **Reduced latency**: Execute multiple operations in a single round trip
- **Atomic workflows**: Group related operations together
- **Better error handling**: See which operations succeeded vs failed
- **Improved efficiency**: Minimize AI agent cycles for complex tasks

### Example Workflows

#### 1. Issue Analysis and Response
```json
{
  "commands": [
    {"tool": "get_issue", "args": {"owner": "...", "repo": "...", "issue_number": 123}},
    {"tool": "get_issue_comments", "args": {"owner": "...", "repo": "...", "issue_number": 123}},
    {"tool": "search_pull_requests", "args": {"query": "is:pr is:merged fixes #123"}}
  ]
}
```

#### 2. Create PR with Review Request
```json
{
  "commands": [
    {"tool": "create_pull_request", "args": {"owner": "...", "repo": "...", "title": "...", "head": "...", "base": "..."}},
    {"tool": "request_copilot_review", "args": {"owner": "...", "repo": "...", "pullNumber": 456}}
  ]
}
```

## Configuration

The server is configured through environment variables:

- `GITHUB_PERSONAL_ACCESS_TOKEN`: GitHub personal access token (required)
- `GITHUB_TOOLSETS`: Comma-separated list of toolsets to enable (default: "all")
- `GITHUB_DYNAMIC_TOOLSETS`: Enable dynamic toolset discovery (default: false)
- `GITHUB_READ_ONLY`: Restrict to read-only operations (default: false)

## Building

```bash
cd cmd/github-mcp-server
go build -o github-mcp-server
```

## Testing

```bash
go test ./...
```

## Architecture Notes

The GitHub MCP server uses a toolset-based architecture where:
- Tools are organized into logical groups (toolsets)
- Each toolset can be enabled/disabled independently
- Tool handlers are registered dynamically when toolsets are enabled
- The batch execution system maintains a registry of all available tool handlers