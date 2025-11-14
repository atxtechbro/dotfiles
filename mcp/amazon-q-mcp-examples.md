# Amazon Q CLI MCP Server Examples

## Practical MCP Server Configurations

### 1. Git Operations Server (Battle-Tested)

Our proven git-mcp-server configuration:

```bash
# Add the git server
q mcp add --name git-ops --command "uvx" --args "atxtechbro-git-mcp-server"

# Verify it's working
q mcp status --name git-ops

# Start chat with git tools trusted
q chat --trust-tools=git___git_status,git___git_diff_unstaged,git___git_add,git___git_commit
```

**Available Tools**:
- `git___git_status` - Check repository status
- `git___git_diff_unstaged` - View unstaged changes
- `git___git_diff_staged` - View staged changes
- `git___git_add` - Stage files
- `git___git_commit` - Commit changes
- `git___git_log` - View commit history
- `git___git_create_branch` - Create new branches
- `git___git_checkout` - Switch branches

### 2. AWS EKS Management Server

```bash
# Add EKS server with full permissions
q mcp add --name eks-mgmt \
  --command "uvx" \
  --args "awslabs.eks-mcp-server,--allow-write,--allow-sensitive-data-access" \
  --env "AWS_REGION=us-west-2,AWS_PROFILE=default"

# For read-only operations
q mcp add --name eks-readonly \
  --command "uvx" \
  --args "awslabs.eks-mcp-server" \
  --env "AWS_REGION=us-west-2"
```

### 3. Filesystem Operations Server

```bash
# Add filesystem server
q mcp add --name filesystem \
  --command "uvx" \
  --args "mcp-server-filesystem" \
  --timeout 5000

# Trust common filesystem tools
q chat --trust-tools=filesystem___read_file,filesystem___write_file,filesystem___list_directory
```

### 4. Database Operations Server

```bash
# PostgreSQL server
q mcp add --name postgres \
  --command "uvx" \
  --args "mcp-server-postgres" \
  --env "DATABASE_URL=postgresql://user:pass@localhost:5432/mydb"

# SQLite server (simpler setup)
q mcp add --name sqlite \
  --command "uvx" \
  --args "mcp-server-sqlite,--db-path,./data.db"
```

### 5. Web Scraping Server

```bash
# Puppeteer-based web scraping
q mcp add --name web-scraper \
  --command "uvx" \
  --args "mcp-server-puppeteer" \
  --timeout 15000  # Longer timeout for browser startup
```

### 6. Slack Integration Server

```bash
# Slack operations
q mcp add --name slack \
  --command "uvx" \
  --args "mcp-server-slack" \
  --env "SLACK_BOT_TOKEN=xoxb-your-token,SLACK_APP_TOKEN=xapp-your-token"
```

## Multi-Server Configurations

### Development Environment Setup

```bash
# Core development tools
q mcp add --name git --command "uvx" --args "atxtechbro-git-mcp-server" --scope workspace
q mcp add --name filesystem --command "uvx" --args "mcp-server-filesystem" --scope workspace
q mcp add --name postgres --command "uvx" --args "mcp-server-postgres" --scope workspace

# Start development session with all tools
q chat --trust-tools=git___git_status,filesystem___read_file,postgres___query
```

### AWS Operations Setup

```bash
# Multiple AWS services
q mcp add --name eks --command "uvx" --args "awslabs.eks-mcp-server" --scope global
q mcp add --name s3 --command "uvx" --args "mcp-server-s3" --scope global
q mcp add --name lambda --command "uvx" --args "mcp-server-lambda" --scope global

# AWS-focused chat session
q chat --trust-tools=eks___list_clusters,s3___list_buckets,lambda___list_functions
```

## Configuration File Examples

### Team Shared Configuration

Create `~/team-mcp-config.json`:

```json
{
  "mcpServers": {
    "team-git": {
      "command": "uvx",
      "args": ["atxtechbro-git-mcp-server"],
      "timeout": 5000
    },
    "shared-db": {
      "command": "uvx",
      "args": ["mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://team:password@db.company.com:5432/shared"
      }
    },
    "company-slack": {
      "command": "uvx",
      "args": ["mcp-server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${COMPANY_SLACK_TOKEN}"
      }
    }
  }
}
```

Use with:
```bash
q chat --mcp-config-paths ~/team-mcp-config.json
```

### Project-Specific Configuration

Create `.q/mcp.json` in your project:

```json
{
  "mcpServers": {
    "project-db": {
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "./project.db"]
    },
    "project-api": {
      "command": "python",
      "args": ["-m", "my_project.mcp_server"],
      "env": {
        "PROJECT_ROOT": "."
      }
    }
  }
}
```

## Advanced Usage Patterns

### Conditional Server Loading

```bash
# Development servers (only when needed)
q mcp add --name debug-server --command "debug-mcp-server" --disabled

# Enable when debugging
q mcp remove --name debug-server
q mcp add --name debug-server --command "debug-mcp-server"  # enabled by default
```

### Environment-Specific Configurations

```bash
# Production environment
if [ "$ENV" = "production" ]; then
  q mcp add --name prod-db --command "uvx" --args "mcp-server-postgres" \
    --env "DATABASE_URL=$PROD_DB_URL"
else
  q mcp add --name dev-db --command "uvx" --args "mcp-server-sqlite" \
    --args "--db-path,./dev.db"
fi
```

### Tool Permission Management

```bash
# Conservative permissions (read-only tools)
q chat --trust-tools=git___git_status,filesystem___read_file,postgres___query

# Development permissions (includes write operations)
q chat --trust-tools=git___git_commit,filesystem___write_file,postgres___execute

# Full permissions (use with caution)
q chat --trust-tools=git___git_add,git___git_commit,filesystem___write_file,postgres___execute,slack___send_message
```

## Troubleshooting Examples

### Server Won't Start

```bash
# Check server status
q mcp status --name problematic-server

# Try with verbose logging
q mcp add --name test-server --command "your-command" --timeout 10000
q chat -vvv  # Check logs for startup issues
```

### Tools Not Available

```bash
# List all configured servers
q mcp list

# Check if server is disabled
q mcp status --name your-server

# Verify tool names (they include server prefix)
q chat --trust-tools=server-name___tool-name
```

### Protocol Issues

Use our proven smoke test approach:

```bash
# Test server directly
(echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "test", "version": "1.0.0"}}}'; echo '{"jsonrpc": "2.0", "method": "notifications/initialized"}'; echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}') | uvx your-mcp-server
```

## Performance Optimization

### Server Startup Optimization

```bash
# Increase timeout for slow servers
q mcp add --name slow-server --command "slow-command" --timeout 30000

# Use faster alternatives when available
q mcp add --name fast-git --command "uvx" --args "atxtechbro-git-mcp-server"  # Our optimized version
```

### Resource Management

```bash
# Disable unused servers
q mcp add --name occasional-server --command "server" --disabled

# Use workspace scope for project-specific servers
q mcp add --name project-server --command "server" --scope workspace
```

## Integration with Development Workflow

### Git Workflow Enhancement

```bash
# Set up git server
q mcp add --name git --command "uvx" --args "atxtechbro-git-mcp-server"

# Create alias for git-enhanced chat
alias qgit='q chat --trust-tools=git___git_status,git___git_diff_unstaged,git___git_add,git___git_commit'

# Use in development
qgit  # Now you can ask Q to check status, stage files, commit changes, etc.
```

### Database Development

```bash
# Set up database server
q mcp add --name db --command "uvx" --args "mcp-server-postgres" \
  --env "DATABASE_URL=postgresql://localhost:5432/myapp"

# Database-focused chat
alias qdb='q chat --trust-tools=postgres___query,postgres___execute,postgres___describe'

# Use for database operations
qdb  # Ask Q to run queries, describe tables, etc.
```

### AWS Operations

```bash
# Set up AWS servers
q mcp add --name aws-eks --command "uvx" --args "awslabs.eks-mcp-server"
q mcp add --name aws-s3 --command "uvx" --args "mcp-server-s3"

# AWS operations chat
alias qaws='q chat --trust-tools=eks___list_clusters,s3___list_buckets'

# Use for AWS management
qaws  # Ask Q to list clusters, check S3 buckets, etc.
```

These examples demonstrate the power and flexibility of Amazon Q CLI's MCP integration, building on our proven experience with MCP server development and testing.
