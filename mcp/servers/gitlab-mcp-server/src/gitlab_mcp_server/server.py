"""GitLab MCP Server - Pipeline debugging focused wrapper around glab CLI."""

import json
import logging
from typing import Any, Dict, List, Optional, Sequence
from mcp.server import Server
from mcp.types import (
    Resource,
    Tool,
    TextContent,
    ImageContent,
    EmbeddedResource,
    LoggingLevel,
)
from pydantic import BaseModel, Field
import mcp.server.stdio

from .utils import run_glab_command, GlabError, format_response
from .pipeline_handlers import get_pipeline_tools, handle_pipeline_tool
from .project_handlers import get_project_tools, handle_project_tool
from .basic_handlers import get_basic_tools, handle_basic_tool
from .user_group_handlers import get_user_group_tools, handle_user_group_tool
from .issue_handlers import get_issue_tools, handle_issue_tool
from .merge_request_handlers import get_merge_request_tools, handle_merge_request_tool


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Server("gitlab-mcp-server")


@app.list_tools()
async def list_tools() -> List[Tool]:
    """List available GitLab tools."""
    tools = []
    
    # Add tools from handlers
    tools.extend(get_pipeline_tools())
    tools.extend(get_project_tools())
    tools.extend(get_basic_tools())
    tools.extend(get_user_group_tools())
    tools.extend(get_issue_tools())
    tools.extend(get_merge_request_tools())
    
    return tools


@app.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle tool calls."""
    try:
        # Try pipeline tools
        if name in ["gitlab_list_pipelines", "gitlab_get_pipeline", "gitlab_get_pipeline_jobs", "gitlab_get_job_log", "gitlab_get_failed_jobs", "gitlab_retry_job", "gitlab_cancel_pipeline"]:
            return await handle_pipeline_tool(name, arguments)
        
        # Try project tools
        elif name in ["gitlab_list_projects", "gitlab_get_project", "gitlab_create_project", "gitlab_list_branches", "gitlab_get_branch", "gitlab_create_branch", "gitlab_delete_branch", "gitlab_list_tags", "gitlab_get_tag", "gitlab_create_tag", "gitlab_delete_tag"]:
            return await handle_project_tool(name, arguments)
        
        # Basic GitLab Operations
        elif name in ["gitlab_list_issues", "gitlab_get_issue", "gitlab_list_merge_requests", "gitlab_get_merge_request", "gitlab_get_file"]:
            return await handle_basic_tool(name, arguments)
        
        # Phase 2: User & Group Management
        elif name in ["gitlab_get_user", "gitlab_list_users", "gitlab_get_current_user", "gitlab_list_groups", "gitlab_get_group", "gitlab_list_group_members", "gitlab_list_project_members"]:
            return await handle_user_group_tool(name, arguments)
        
        # Issue Management
        elif name in ["gitlab_create_issue", "gitlab_update_issue", "gitlab_close_issue", "gitlab_reopen_issue", "gitlab_list_issue_comments", "gitlab_create_issue_comment", "gitlab_list_project_labels", "gitlab_create_project_label", "gitlab_list_project_milestones", "gitlab_create_project_milestone"]:
            return await handle_issue_tool(name, arguments)
        
        # Merge Request Operations
        elif name in ["gitlab_create_merge_request", "gitlab_update_merge_request", "gitlab_merge_merge_request", "gitlab_close_merge_request", "gitlab_reopen_merge_request", "gitlab_list_mr_comments", "gitlab_create_mr_comment", "gitlab_get_mr_diff", "gitlab_get_mr_changes", "gitlab_approve_merge_request", "gitlab_unapprove_merge_request"]:
            return await handle_merge_request_tool(name, arguments)
        else:
            raise ValueError(f"Unknown tool: {name}")
    except Exception as e:
        logger.error(f"Error in tool {name}: {e}")
        return [TextContent(type="text", text=f"Error: {str(e)}")]


if __name__ == "__main__":
    mcp.server.stdio.run_stdio_server(app)
