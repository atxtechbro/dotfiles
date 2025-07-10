"""Basic GitLab operations handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_basic_tools() -> List[Tool]:
    """Get basic GitLab operation tools."""
    return [
        Tool(
            name="gitlab_list_issues",
            description="List issues in a project",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "state": {
                        "type": "string",
                        "description": "Filter by state (opened, closed, all)"
                    },
                    "assignee": {
                        "type": "string",
                        "description": "Filter by assignee username"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of issues to return (default: 10)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_issue",
            description="Get details of a specific issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "issue_id": {
                        "type": "integer",
                        "description": "Issue ID"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["issue_id"]
            }
        ),
        Tool(
            name="gitlab_list_merge_requests",
            description="List merge requests in a project",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "state": {
                        "type": "string",
                        "description": "Filter by state (opened, closed, merged, all)"
                    },
                    "assignee": {
                        "type": "string",
                        "description": "Filter by assignee username"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of MRs to return (default: 10)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_merge_request",
            description="Get details of a specific merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_get_file",
            description="Get file contents from a GitLab repository",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_path": {
                        "type": "string",
                        "description": "Path to the file in the repository"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "branch": {
                        "type": "string",
                        "description": "Branch name (default: main/master)"
                    }
                },
                "required": ["file_path"]
            }
        )
    ]


async def handle_basic_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle basic tool calls."""
    if name == "gitlab_list_issues":
        return await handle_list_issues(arguments)
    elif name == "gitlab_get_issue":
        return await handle_get_issue(arguments)
    elif name == "gitlab_list_merge_requests":
        return await handle_list_merge_requests(arguments)
    elif name == "gitlab_get_merge_request":
        return await handle_get_merge_request(arguments)
    elif name == "gitlab_get_file":
        return await handle_get_file(arguments)
    else:
        raise ValueError(f"Unknown basic tool: {name}")


# Basic GitLab Operations Handlers

async def handle_list_issues(args: Dict[str, Any]) -> List[TextContent]:
    """List issues in a project."""
    cmd = ["issue", "list"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    # Handle state filtering - glab issue list uses specific flags
    state = args.get("state", "opened").lower()
    if state == "opened":
        cmd.append("--opened")
    elif state == "closed":
        cmd.append("--closed")
    elif state == "all":
        cmd.append("--all")
    
    if args.get("assignee"):
        cmd.extend(["--assignee", args["assignee"]])
    
    # Use API for limit control if specified
    if args.get("limit"):
        # Use API approach for pagination control
        cmd = ["api", "projects/:id/issues"]
        if args.get("project"):
            cmd.extend(["--repo", args["project"]])
        cmd.extend(["--field", f"per_page={args['limit']}"])
        
        # Add state to API call
        if state == "opened":
            cmd.extend(["--field", "state=opened"])
        elif state == "closed":
            cmd.extend(["--field", "state=closed"])
        
        if args.get("assignee"):
            cmd.extend(["--field", f"assignee_username={args['assignee']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Get details of a specific issue."""
    issue_id = args["issue_id"]
    cmd = ["issue", "view", str(issue_id)]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_merge_requests(args: Dict[str, Any]) -> List[TextContent]:
    """List merge requests in a project."""
    cmd = ["mr", "list"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    # Handle state filtering - glab mr list uses specific flags, not --state
    state = args.get("state", "opened").lower()
    if state == "opened":
        cmd.append("--opened")
    elif state == "closed":
        cmd.append("--closed")
    elif state == "merged":
        cmd.append("--merged")
    elif state == "all":
        cmd.append("--all")
    
    if args.get("assignee"):
        cmd.extend(["--assignee", args["assignee"]])
    
    # Handle limit using API pagination instead of --limit flag
    if args.get("limit"):
        # Use API approach for pagination control
        cmd = ["api", "projects/:id/merge_requests"]
        if args.get("project"):
            cmd.extend(["--repo", args["project"]])
        cmd.extend(["--field", f"per_page={args['limit']}"])
        
        # Add state to API call
        if state == "opened":
            cmd.extend(["--field", "state=opened"])
        elif state == "closed":
            cmd.extend(["--field", "state=closed"])
        elif state == "merged":
            cmd.extend(["--field", "state=merged"])
        
        if args.get("assignee"):
            cmd.extend(["--field", f"assignee_username={args['assignee']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Get details of a specific merge request."""
    mr_id = args["mr_id"]
    cmd = ["mr", "view", str(mr_id)]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_file(args: Dict[str, Any]) -> List[TextContent]:
    """Get file contents from a GitLab repository."""
    file_path = args["file_path"]
    cmd = ["api", f"projects/:id/repository/files/{file_path.replace('/', '%2F')}/raw"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("branch"):
        cmd.extend(["--field", f"ref={args['branch']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]