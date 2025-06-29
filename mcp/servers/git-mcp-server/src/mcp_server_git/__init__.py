import logging
import sys
from pathlib import Path

import click

from .server import serve

@click.command()
@click.option("--repository", "-r", type=Path, help="Git repository path")
@click.option("-v", "--verbose", count=True)
@click.option("--read-only", is_flag=True, help="Run in read-only mode (no write operations)")
def main(repository: Path | None, verbose: bool, read_only: bool) -> None:
    """MCP Git Server - Git functionality for MCP"""
    import asyncio

    logging_level = logging.WARN
    if verbose == 1:
        logging_level = logging.INFO
    elif verbose >= 2:
        logging_level = logging.DEBUG

    logging.basicConfig(level=logging_level, stream=sys.stderr)
    asyncio.run(serve(repository, read_only))

if __name__ == "__main__":
    main()
