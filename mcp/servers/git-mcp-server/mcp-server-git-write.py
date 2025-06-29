#!/usr/bin/env python
"""Entry point for git MCP write server"""
import sys
from pathlib import Path
from mcp_server_git.server_write import serve
import asyncio

if __name__ == "__main__":
    repository = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    asyncio.run(serve(repository))