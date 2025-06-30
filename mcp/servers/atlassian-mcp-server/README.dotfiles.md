# Atlassian MCP Server (Forked)

This is a fork of [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian) maintained in-house for self-hosted Atlassian support.

## Why Fork?

The upstream mcp-atlassian tool claims to support self-hosted Atlassian instances (Server/Data Center) but has incomplete implementation:

1. **Authentication Issues**: While it accepts personal tokens, it doesn't handle self-hosted auth flows correctly (session cookies, different API endpoints)
2. **Permission Errors**: API calls fail with permission errors even after successful authentication
3. **Empty Results**: Methods like `jira_get_all_projects` return empty arrays instead of actual data
4. **Maintenance Control**: We need to quickly fix issues without waiting for upstream PRs

## Our Improvements

1. **Better Self-Hosted Support**: Proper handling of self-hosted authentication including session management
2. **Enhanced Logging**: Detailed logging to understand auth flows and debug issues
3. **Corporate Environment**: Tailored for instances behind corporate auth (VPN, SSO, etc.)
4. **Custom Features**: Organization-specific functionality as needed

## Development Setup

```bash
# Create virtual environment
cd mcp/servers/atlassian-mcp-server
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -e .

# Run the server
python -m mcp_atlassian
```

## Testing

```bash
# Run tests
pytest

# Test with real data (requires credentials)
./scripts/test_with_real_data.sh
```

## Original Documentation

See [README.md](README.md) for the original upstream documentation.

## License

This fork maintains the MIT license from the original project.