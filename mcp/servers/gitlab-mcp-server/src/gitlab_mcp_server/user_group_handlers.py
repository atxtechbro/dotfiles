"""User and group management handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_user_group_tools() -> List[Tool]:
    """Get user and group management tools."""
    return [
        # Phase 2: User & Group Management
        Tool(
            name="gitlab_get_user",
            description="Get user details by username or user ID",
            inputSchema={
                "type": "object",
                "properties": {
                    "username": {
                        "type": "string",
                        "description": "Username or user ID"
                    }
                },
                "required": ["username"]
            }
        ),
        Tool(
            name="gitlab_list_users",
            description="List users with optional filtering",
            inputSchema={
                "type": "object",
                "properties": {
                    "search": {
                        "type": "string",
                        "description": "Search term for username or email"
                    },
                    "active": {
                        "type": "boolean",
                        "description": "Filter active users only"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of users to return (default: 20)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_current_user",
            description="Get current authenticated user details",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="gitlab_list_groups",
            description="List groups with optional filtering",
            inputSchema={
                "type": "object",
                "properties": {
                    "search": {
                        "type": "string",
                        "description": "Search term for group name"
                    },
                    "owned": {
                        "type": "boolean",
                        "description": "Show only owned groups"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of groups to return (default: 20)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_group",
            description="Get group details by path or group ID",
            inputSchema={
                "type": "object",
                "properties": {
                    "group": {
                        "type": "string",
                        "description": "Group path or group ID"
                    }
                },
                "required": ["group"]
            }
        ),
        Tool(
            name="gitlab_list_group_members",
            description="List members of a group",
            inputSchema={
                "type": "object",
                "properties": {
                    "group": {
                        "type": "string",
                        "description": "Group path or group ID"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of members to return (default: 20)"
                    }
                },
                "required": ["group"]
            }
        ),
        Tool(
            name="gitlab_list_project_members",
            description="List members of a project",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of members to return (default: 20)"
                    }
                }
            }
        ),
    ]


async def handle_user_group_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle user and group tool calls."""
    # Phase 2: User & Group Management
    if name == "gitlab_get_user":
        return await handle_get_user(arguments)
    elif name == "gitlab_list_users":
        return await handle_list_users(arguments)
    elif name == "gitlab_get_current_user":
        return await handle_get_current_user(arguments)
    elif name == "gitlab_list_groups":
        return await handle_list_groups(arguments)
    elif name == "gitlab_get_group":
        return await handle_get_group(arguments)
    elif name == "gitlab_list_group_members":
        return await handle_list_group_members(arguments)
    elif name == "gitlab_list_project_members":
        return await handle_list_project_members(arguments)
    else:
        raise ValueError(f"Unknown user/group tool: {name}")


# Phase 2: User & Group Management Handlers

async def handle_get_user(args: Dict[str, Any]) -> List[TextContent]:
    """Get user details."""
    username = args["username"]
    cmd = ["api", f"users/{username}"]
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_users(args: Dict[str, Any]) -> List[TextContent]:
    """List users with optional filtering."""
    cmd = ["api", "users"]
    
    if args.get("search"):
        cmd.extend(["--field", f"search={args['search']}"])
    if args.get("active"):
        cmd.extend(["--field", "active=true"])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_current_user(args: Dict[str, Any]) -> List[TextContent]:
    """Get current authenticated user details."""
    cmd = ["api", "user"]
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_groups(args: Dict[str, Any]) -> List[TextContent]:
    """List groups with optional filtering."""
    cmd = ["api", "groups"]
    
    if args.get("search"):
        cmd.extend(["--field", f"search={args['search']}"])
    if args.get("owned"):
        cmd.extend(["--field", "owned=true"])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_group(args: Dict[str, Any]) -> List[TextContent]:
    """Get group details."""
    group = args["group"]
    cmd = ["api", f"groups/{group}"]
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_group_members(args: Dict[str, Any]) -> List[TextContent]:
    """List members of a group."""
    group = args["group"]
    cmd = ["api", f"groups/{group}/members"]
    
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_project_members(args: Dict[str, Any]) -> List[TextContent]:
    """List members of a project."""
    cmd = ["api", "projects/:id/members"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]