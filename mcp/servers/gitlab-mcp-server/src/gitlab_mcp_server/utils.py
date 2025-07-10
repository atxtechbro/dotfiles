"""Shared utilities for GitLab MCP Server."""

import json
import subprocess
import asyncio
import logging
from typing import Any, Dict, List
from mcp.types import TextContent

logger = logging.getLogger(__name__)


class GlabError(Exception):
    """Custom exception for glab CLI errors."""
    pass


async def run_glab_command(args: List[str]) -> Dict[str, Any]:
    """Run a glab command and return JSON output."""
    try:
        result = subprocess.run(
            ["glab"] + args,
            capture_output=True,
            text=True,
            check=True,
            timeout=30
        )
        
        # For commands that return JSON, parse it
        if result.stdout.strip():
            try:
                return json.loads(result.stdout)
            except json.JSONDecodeError as e:
                # Handle HTML error responses (like authentication issues)
                if result.stdout.strip().startswith('<'):
                    logger.warning(f"Received HTML response instead of JSON: {result.stdout[:200]}...")
                    return {"error": "HTML response received - likely authentication or GitLab configuration issue", "raw_output": result.stdout.strip()}
                # Return raw text for other non-JSON responses
                logger.warning(f"Non-JSON response: {e}")
                return {"output": result.stdout.strip()}
        
        return {"success": True, "message": "Command executed successfully"}
        
    except subprocess.CalledProcessError as e:
        logger.error(f"glab command failed: {e}")
        raise GlabError(f"glab command failed: {e.stderr}")
    except subprocess.TimeoutExpired:
        logger.error("glab command timed out")
        raise GlabError("glab command timed out")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise GlabError(f"Unexpected error: {str(e)}")


def format_response(result: Dict[str, Any]) -> List[TextContent]:
    """Format response as TextContent."""
    return [TextContent(type="text", text=json.dumps(result, indent=2))]