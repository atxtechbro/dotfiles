# PostgreSQL MCP Server

The PostgreSQL MCP server allows AI assistants to query and interact with PostgreSQL databases.

## Installation

The PostgreSQL MCP server is installed automatically via NPX when configured in your MCP configuration file.

## Configuration

Basic configuration:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://USERNAME:PASSWORD@HOST:5432/DBNAME"
      ]
    }
  }
}
```

Replace `USERNAME`, `PASSWORD`, `HOST`, and `DBNAME` with your PostgreSQL connection details.

## Security Considerations

The connection string contains sensitive information. Consider:

1. Using environment variables:
   ```json
   {
     "mcpServers": {
       "postgres": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-postgres",
           "$POSTGRES_CONNECTION_STRING"
         ],
         "env": {
           "POSTGRES_CONNECTION_STRING": "postgresql://USERNAME:PASSWORD@HOST:5432/DBNAME"
         }
       }
     }
   }
   ```

2. Storing the connection string in your `~/.bash_secrets` file and having the setup script inject it.

## Capabilities

With the PostgreSQL MCP server, AI assistants can:

- Query database schema information
- Execute SELECT queries
- Analyze data
- Generate SQL queries based on natural language requests
- Visualize query results

## Troubleshooting

If you encounter issues with the PostgreSQL MCP server:

1. Verify your PostgreSQL connection string is correct
2. Check if the server is running: `ps aux | grep server-postgres`
3. Test the connection manually: `psql "postgresql://USERNAME:PASSWORD@HOST:5432/DBNAME"`

## Additional Resources

- [PostgreSQL MCP Server Documentation](https://github.com/modelcontextprotocol/server-postgres)
- [Model Context Protocol](https://modelcontextprotocol.github.io/)
