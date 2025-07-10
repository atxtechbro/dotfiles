"""Project, branch, and tag handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_project_tools() -> List[Tool]:
    """Get project management tools."""
    return [
        # Project Management
        Tool(
            name="gitlab_list_projects",
            description="List accessible projects",
            inputSchema={
                "type": "object",
                "properties": {
                    "group": {
                        "type": "string",
                        "description": "Filter by group name"
                    },
                    "owned": {
                        "type": "boolean",
                        "description": "Show only owned projects"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of projects to return (default: 10)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_project",
            description="Get project details",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project') or project ID"
                    }
                },
                "required": ["project"]
            }
        ),
        Tool(
            name="gitlab_create_project",
            description="Create new project",
            inputSchema={
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Project name"
                    },
                    "path": {
                        "type": "string",
                        "description": "Project path (URL-friendly name)"
                    },
                    "description": {
                        "type": "string",
                        "description": "Project description"
                    },
                    "visibility": {
                        "type": "string",
                        "description": "Project visibility (private, internal, public)"
                    },
                    "group": {
                        "type": "string",
                        "description": "Group to create project in"
                    }
                },
                "required": ["name"]
            }
        ),
        
        # Branch Management
        Tool(
            name="gitlab_list_branches",
            description="List project branches",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of branches to return (default: 10)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_branch",
            description="Get branch details",
            inputSchema={
                "type": "object",
                "properties": {
                    "branch": {
                        "type": "string",
                        "description": "Branch name"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["branch"]
            }
        ),
        Tool(
            name="gitlab_create_branch",
            description="Create new branch",
            inputSchema={
                "type": "object",
                "properties": {
                    "branch": {
                        "type": "string",
                        "description": "New branch name"
                    },
                    "ref": {
                        "type": "string",
                        "description": "Branch or commit to create from (default: main)"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["branch"]
            }
        ),
        Tool(
            name="gitlab_delete_branch",
            description="Delete branch",
            inputSchema={
                "type": "object",
                "properties": {
                    "branch": {
                        "type": "string",
                        "description": "Branch name to delete"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["branch"]
            }
        ),
        
        # Tag Management
        Tool(
            name="gitlab_list_tags",
            description="List project tags",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of tags to return (default: 10)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_tag",
            description="Get tag details",
            inputSchema={
                "type": "object",
                "properties": {
                    "tag": {
                        "type": "string",
                        "description": "Tag name"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["tag"]
            }
        ),
        Tool(
            name="gitlab_create_tag",
            description="Create new tag",
            inputSchema={
                "type": "object",
                "properties": {
                    "tag": {
                        "type": "string",
                        "description": "Tag name"
                    },
                    "ref": {
                        "type": "string",
                        "description": "Branch or commit to tag (default: main)"
                    },
                    "message": {
                        "type": "string",
                        "description": "Tag message"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["tag"]
            }
        ),
        Tool(
            name="gitlab_delete_tag",
            description="Delete tag",
            inputSchema={
                "type": "object",
                "properties": {
                    "tag": {
                        "type": "string",
                        "description": "Tag name to delete"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["tag"]
            }
        ),
    ]


async def handle_project_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle project tool calls."""
    try:
        # Project Management
        if name == "gitlab_list_projects":
            return await handle_list_projects(arguments)
        elif name == "gitlab_get_project":
            return await handle_get_project(arguments)
        elif name == "gitlab_create_project":
            return await handle_create_project(arguments)
        
        # Branch Management
        elif name == "gitlab_list_branches":
            return await handle_list_branches(arguments)
        elif name == "gitlab_get_branch":
            return await handle_get_branch(arguments)
        elif name == "gitlab_create_branch":
            return await handle_create_branch(arguments)
        elif name == "gitlab_delete_branch":
            return await handle_delete_branch(arguments)
        
        # Tag Management
        elif name == "gitlab_list_tags":
            return await handle_list_tags(arguments)
        elif name == "gitlab_get_tag":
            return await handle_get_tag(arguments)
        elif name == "gitlab_create_tag":
            return await handle_create_tag(arguments)
        elif name == "gitlab_delete_tag":
            return await handle_delete_tag(arguments)
        
        else:
            raise ValueError(f"Unknown project tool: {name}")
    except Exception as e:
        return [TextContent(type="text", text=f"Error: {str(e)}")]


# Project Management Handlers

async def handle_list_projects(args: Dict[str, Any]) -> List[TextContent]:
    """List accessible projects."""
    cmd = ["api", "projects"]
    
    if args.get("group"):
        cmd.extend(["--field", f"search={args['group']}"])
    if args.get("owned"):
        cmd.extend(["--field", "owned=true"])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_project(args: Dict[str, Any]) -> List[TextContent]:
    """Get project details."""
    project = args["project"]
    
    # Use glab repo view for project details
    cmd = ["repo", "view", project, "--output", "json"]
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_project(args: Dict[str, Any]) -> List[TextContent]:
    """Create new project."""
    cmd = ["repo", "create", args["name"]]
    
    if args.get("description"):
        cmd.extend(["--description", args["description"]])
    if args.get("visibility"):
        cmd.extend(["--visibility", args["visibility"]])
    if args.get("group"):
        cmd.extend(["--group", args["group"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


# Branch Management Handlers

async def handle_list_branches(args: Dict[str, Any]) -> List[TextContent]:
    """List project branches."""
    cmd = ["api", "projects/:id/repository/branches"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_branch(args: Dict[str, Any]) -> List[TextContent]:
    """Get branch details."""
    branch = args["branch"]
    cmd = ["api", f"projects/:id/repository/branches/{branch}"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_branch(args: Dict[str, Any]) -> List[TextContent]:
    """Create new branch."""
    branch = args["branch"]
    ref = args.get("ref", "main")
    
    cmd = ["api", "projects/:id/repository/branches", "--method", "POST"]
    cmd.extend(["--field", f"branch={branch}"])
    cmd.extend(["--field", f"ref={ref}"])
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_delete_branch(args: Dict[str, Any]) -> List[TextContent]:
    """Delete branch."""
    branch = args["branch"]
    cmd = ["api", f"projects/:id/repository/branches/{branch}", "--method", "DELETE"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


# Tag Management Handlers

async def handle_list_tags(args: Dict[str, Any]) -> List[TextContent]:
    """List project tags."""
    cmd = ["api", "projects/:id/repository/tags"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_tag(args: Dict[str, Any]) -> List[TextContent]:
    """Get tag details."""
    tag = args["tag"]
    cmd = ["api", f"projects/:id/repository/tags/{tag}"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_tag(args: Dict[str, Any]) -> List[TextContent]:
    """Create new tag."""
    tag = args["tag"]
    ref = args.get("ref", "main")
    
    cmd = ["api", "projects/:id/repository/tags", "--method", "POST"]
    cmd.extend(["--field", f"tag_name={tag}"])
    cmd.extend(["--field", f"ref={ref}"])
    
    if args.get("message"):
        cmd.extend(["--field", f"message={args['message']}"])
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_delete_tag(args: Dict[str, Any]) -> List[TextContent]:
    """Delete tag."""
    tag = args["tag"]
    cmd = ["api", f"projects/:id/repository/tags/{tag}", "--method", "DELETE"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]