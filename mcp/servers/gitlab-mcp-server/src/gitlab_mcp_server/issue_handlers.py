"""Issue management handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_issue_tools() -> List[Tool]:
    """Get issue management tools."""
    return [
        # Phase 4: Comprehensive Issue Management
        Tool(
            name="gitlab_create_issue",
            description="Create a new issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "title": {
                        "type": "string",
                        "description": "Issue title"
                    },
                    "description": {
                        "type": "string",
                        "description": "Issue description"
                    },
                    "labels": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Issue labels"
                    },
                    "assignees": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Assignee usernames"
                    },
                    "milestone": {
                        "type": "string",
                        "description": "Milestone title"
                    },
                    "due_date": {
                        "type": "string",
                        "description": "Due date (YYYY-MM-DD format)"
                    }
                },
                "required": ["title"]
            }
        ),
        Tool(
            name="gitlab_update_issue",
            description="Update an existing issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "issue_id": {
                        "type": "integer",
                        "description": "Issue ID"
                    },
                    "title": {
                        "type": "string",
                        "description": "New issue title"
                    },
                    "description": {
                        "type": "string",
                        "description": "New issue description"
                    },
                    "labels": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Issue labels"
                    },
                    "assignees": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Assignee usernames"
                    },
                    "state": {
                        "type": "string",
                        "description": "Issue state (opened, closed)"
                    },
                    "milestone": {
                        "type": "string",
                        "description": "Milestone title"
                    }
                },
                "required": ["issue_id"]
            }
        ),
        Tool(
            name="gitlab_close_issue",
            description="Close an issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "issue_id": {
                        "type": "integer",
                        "description": "Issue ID"
                    }
                },
                "required": ["issue_id"]
            }
        ),
        Tool(
            name="gitlab_reopen_issue",
            description="Reopen a closed issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "issue_id": {
                        "type": "integer",
                        "description": "Issue ID"
                    }
                },
                "required": ["issue_id"]
            }
        ),
        Tool(
            name="gitlab_list_issue_comments",
            description="List comments on an issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "issue_id": {
                        "type": "integer",
                        "description": "Issue ID"
                    },
                    "sort": {
                        "type": "string",
                        "description": "Sort order (asc, desc)"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of comments to return"
                    }
                },
                "required": ["issue_id"]
            }
        ),
        Tool(
            name="gitlab_create_issue_comment",
            description="Create a comment on an issue",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "issue_id": {
                        "type": "integer",
                        "description": "Issue ID"
                    },
                    "body": {
                        "type": "string",
                        "description": "Comment text"
                    }
                },
                "required": ["issue_id", "body"]
            }
        ),
        Tool(
            name="gitlab_list_project_labels",
            description="List project labels",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "search": {
                        "type": "string",
                        "description": "Search term for label names"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_create_project_label",
            description="Create a new project label",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "name": {
                        "type": "string",
                        "description": "Label name"
                    },
                    "color": {
                        "type": "string",
                        "description": "Label color (hex format, e.g., #FF0000)"
                    },
                    "description": {
                        "type": "string",
                        "description": "Label description"
                    }
                },
                "required": ["name", "color"]
            }
        ),
        Tool(
            name="gitlab_list_project_milestones",
            description="List project milestones",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "state": {
                        "type": "string",
                        "description": "Filter by state (active, closed, all)"
                    },
                    "search": {
                        "type": "string",
                        "description": "Search term for milestone titles"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_create_project_milestone",
            description="Create a new project milestone",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "title": {
                        "type": "string",
                        "description": "Milestone title"
                    },
                    "description": {
                        "type": "string",
                        "description": "Milestone description"
                    },
                    "due_date": {
                        "type": "string",
                        "description": "Due date (YYYY-MM-DD format)"
                    },
                    "start_date": {
                        "type": "string",
                        "description": "Start date (YYYY-MM-DD format)"
                    }
                },
                "required": ["title"]
            }
        ),
    ]


async def handle_issue_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle issue tool calls."""
    # Issue Management
    if name == "gitlab_create_issue":
        return await handle_create_issue(arguments)
    elif name == "gitlab_update_issue":
        return await handle_update_issue(arguments)
    elif name == "gitlab_close_issue":
        return await handle_close_issue(arguments)
    elif name == "gitlab_reopen_issue":
        return await handle_reopen_issue(arguments)
    elif name == "gitlab_list_issue_comments":
        return await handle_list_issue_comments(arguments)
    elif name == "gitlab_create_issue_comment":
        return await handle_create_issue_comment(arguments)
    elif name == "gitlab_list_project_labels":
        return await handle_list_project_labels(arguments)
    elif name == "gitlab_create_project_label":
        return await handle_create_project_label(arguments)
    elif name == "gitlab_list_project_milestones":
        return await handle_list_project_milestones(arguments)
    elif name == "gitlab_create_project_milestone":
        return await handle_create_project_milestone(arguments)
    else:
        raise ValueError(f"Unknown issue tool: {name}")


async def handle_create_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Create a new issue."""
    cmd = ["issue", "create", "--title", args["title"]]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("description"):
        cmd.extend(["--description", args["description"]])
    if args.get("labels"):
        cmd.extend(["--label", ",".join(args["labels"])])
    if args.get("assignees"):
        cmd.extend(["--assignee", ",".join(args["assignees"])])
    if args.get("milestone"):
        cmd.extend(["--milestone", args["milestone"]])
    if args.get("due_date"):
        cmd.extend(["--due-date", args["due_date"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_update_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Update an existing issue."""
    cmd = ["issue", "update", str(args["issue_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("title"):
        cmd.extend(["--title", args["title"]])
    if args.get("description"):
        cmd.extend(["--description", args["description"]])
    if args.get("labels"):
        cmd.extend(["--label", ",".join(args["labels"])])
    if args.get("assignees"):
        cmd.extend(["--assignee", ",".join(args["assignees"])])
    if args.get("state"):
        cmd.extend(["--state", args["state"]])
    if args.get("milestone"):
        cmd.extend(["--milestone", args["milestone"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_close_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Close an issue."""
    cmd = ["issue", "close", str(args["issue_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_reopen_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Reopen a closed issue."""
    cmd = ["issue", "reopen", str(args["issue_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_issue_comments(args: Dict[str, Any]) -> List[TextContent]:
    """List comments on an issue."""
    cmd = ["api", f"projects/:id/issues/{args['issue_id']}/notes"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("sort"):
        cmd.extend(["--field", f"sort={args['sort']}"])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_issue_comment(args: Dict[str, Any]) -> List[TextContent]:
    """Create a comment on an issue."""
    cmd = ["api", f"projects/:id/issues/{args['issue_id']}/notes", "--method", "POST"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    cmd.extend(["--field", f"body={args['body']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_project_labels(args: Dict[str, Any]) -> List[TextContent]:
    """List project labels."""
    cmd = ["api", "projects/:id/labels"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("search"):
        cmd.extend(["--field", f"search={args['search']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_project_label(args: Dict[str, Any]) -> List[TextContent]:
    """Create a new project label."""
    cmd = ["api", "projects/:id/labels", "--method", "POST"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    cmd.extend(["--field", f"name={args['name']}"])
    cmd.extend(["--field", f"color={args['color']}"])
    if args.get("description"):
        cmd.extend(["--field", f"description={args['description']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_project_milestones(args: Dict[str, Any]) -> List[TextContent]:
    """List project milestones."""
    cmd = ["api", "projects/:id/milestones"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("state"):
        cmd.extend(["--field", f"state={args['state']}"])
    if args.get("search"):
        cmd.extend(["--field", f"search={args['search']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_project_milestone(args: Dict[str, Any]) -> List[TextContent]:
    """Create a new project milestone."""
    cmd = ["api", "projects/:id/milestones", "--method", "POST"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    cmd.extend(["--field", f"title={args['title']}"])
    if args.get("description"):
        cmd.extend(["--field", f"description={args['description']}"])
    if args.get("due_date"):
        cmd.extend(["--field", f"due_date={args['due_date']}"])
    if args.get("start_date"):
        cmd.extend(["--field", f"start_date={args['start_date']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]