# GitLab MCP Server

A Model Context Protocol (MCP) server that provides GitLab integration through the `glab` CLI, with a focus on pipeline debugging and CI/CD operations.

## Features

### Pipeline Operations (Priority)
- **List pipelines** - View CI/CD pipelines with filtering
- **Get pipeline details** - Detailed pipeline information
- **Get pipeline jobs** - List jobs for a specific pipeline
- **Get job logs** - Critical for debugging failed jobs
- **Get failed jobs** - Bulk retrieval of failed jobs with logs
- **Retry jobs** - Retry failed jobs
- **Cancel pipelines** - Cancel running pipelines

### Basic GitLab Operations
- **Issues** - List and view issues
- **Merge Requests** - List and view merge requests
- **Files** - Get file contents from repositories

## Prerequisites

- Python 3.8+
- `glab` CLI installed and authenticated
- GitLab account with appropriate permissions

## Installation

1. Install the package:
```bash
pip install -e .
```

2. Ensure `glab` is installed and authenticated:
```bash
# Install glab (if not already installed)
# macOS: brew install glab
# Linux: See https://gitlab.com/gitlab-org/cli/-/releases

# Authenticate with GitLab
glab auth login
```

## Usage

### As MCP Server
Add to your MCP client configuration:

```json
{
  "mcpServers": {
    "gitlab": {
      "command": "gitlab-mcp-server",
      "args": []
    }
  }
}
```

### Direct Usage
```bash
# Run the server
gitlab-mcp-server

# Or via Python module
python -m gitlab_mcp_server
```

## Tools

### Pipeline Debugging (Priority)

#### `gitlab_get_failed_jobs`
Get all failed jobs from a pipeline with their logs - essential for debugging.

```json
{
  "pipeline_id": 123456,
  "project": "group/project",
  "include_logs": true
}
```

#### `gitlab_get_job_log`
Get logs for a specific job.

```json
{
  "job_id": 789012,
  "project": "group/project"
}
```

#### `gitlab_list_pipelines`
List pipelines with filtering options.

```json
{
  "project": "group/project",
  "status": "failed",
  "limit": 20
}
```

### Other Operations

#### `gitlab_list_issues`
List project issues.

#### `gitlab_get_merge_request`
Get merge request details.

#### `gitlab_get_file`
Get file contents from repository.

## Architecture

This server is a lightweight wrapper around the `glab` CLI tool, providing:

1. **JSON API** - Structured responses for all operations
2. **Error handling** - Proper error messages and timeouts
3. **Pipeline focus** - Prioritizes CI/CD debugging workflows
4. **Async support** - Non-blocking operations

## Development

1. Clone the repository
2. Install development dependencies:
```bash
pip install -e ".[dev]"
```

3. Run tests:
```bash
pytest
```

4. Format code:
```bash
black src/
isort src/
```

## License

MIT License - see LICENSE file for details.