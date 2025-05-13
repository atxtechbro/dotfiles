#!/bin/bash

# =========================================================
# MSSQL MCP WRAPPER SCRIPT
# =========================================================
# PURPOSE: Runtime wrapper that executes the MCP MSSQL server
# This script is called by the MCP system during normal operation
# It loads credentials from ~/.bash_secrets and passes them to the server
# 
# RELATIONSHIP: This is the runtime component that gets executed by the
# MCP system. The setup-mssql-mcp.sh script is the one-time setup
# script that prepares your environment for using this wrapper.
# =========================================================

# Source secrets file if it exists
if [ -f ~/.bash_secrets ]; then
  source ~/.bash_secrets
else
  echo "Error: ~/.bash_secrets file not found. Please create it using the template." >&2
  exit 1
fi

# Check if required environment variables are set
if [ -z "$MSSQL_DRIVER" ] || [ -z "$MSSQL_HOST" ] || [ -z "$MSSQL_USER" ] || \
   [ -z "$MSSQL_PASSWORD" ] || [ -z "$MSSQL_DATABASE" ]; then
  echo "Error: Missing required MSSQL credentials in ~/.bash_secrets" >&2
  echo "Please add the following variables to your ~/.bash_secrets file:" >&2
  echo "  export MSSQL_DRIVER=\"your_mssql_driver\"" >&2
  echo "  export MSSQL_HOST=\"localhost\"" >&2
  echo "  export MSSQL_USER=\"your_username\"" >&2
  echo "  export MSSQL_PASSWORD=\"your_password\"" >&2
  echo "  export MSSQL_DATABASE=\"your_database\"" >&2
  echo "  export MSSQL_TRUST_SERVER_CERT=\"yes\"  # Optional" >&2
  echo "  export MSSQL_TRUSTED_CONNECTION=\"no\"  # Optional" >&2
  exit 1
fi

# Run the MCP MSSQL server with credentials from environment variables
exec uvx mssql-mcp-server \
  --driver="$MSSQL_DRIVER" \
  --host="$MSSQL_HOST" \
  --user="$MSSQL_USER" \
  --password="$MSSQL_PASSWORD" \
  --database="$MSSQL_DATABASE" \
  ${MSSQL_TRUST_SERVER_CERT:+--trust-server-cert="$MSSQL_TRUST_SERVER_CERT"} \
  ${MSSQL_TRUSTED_CONNECTION:+--trusted-connection="$MSSQL_TRUSTED_CONNECTION"}
