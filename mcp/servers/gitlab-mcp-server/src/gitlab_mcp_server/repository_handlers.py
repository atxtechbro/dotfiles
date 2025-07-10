"""Advanced repository operations handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_repository_tools() -> List[Tool]:
    """Get advanced repository operation tools."""
    return [
        # Phase 3: Advanced Repository Operations
        Tool(
            name="gitlab_fork_project",
            description="Fork a project to user's namespace or a group",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project')"
                    },
                    "namespace": {
                        "type": "string",
                        "description": "Target namespace (group or user) for the fork"
                    }
                },
                "required": ["project"]
            }
        ),
        Tool(
            name="gitlab_list_commits",
            description="List commits in a project or branch",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "branch": {
                        "type": "string",
                        "description": "Branch name (default: main)"
                    },
                    "author": {
                        "type": "string",
                        "description": "Filter by author username"
                    },
                    "since": {
                        "type": "string",
                        "description": "Filter commits since date (ISO format)"
                    },
                    "until": {
                        "type": "string",
                        "description": "Filter commits until date (ISO format)"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of commits to return (default: 20)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_commit",
            description="Get commit details by SHA",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "sha": {
                        "type": "string",
                        "description": "Commit SHA"
                    }
                },
                "required": ["sha"]
            }
        ),
        Tool(
            name="gitlab_compare_branches",
            description="Compare two branches or commits",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "from": {
                        "type": "string",
                        "description": "Source branch or commit SHA"
                    },
                    "to": {
                        "type": "string",
                        "description": "Target branch or commit SHA"
                    }
                },
                "required": ["from", "to"]
            }
        ),
        Tool(
            name="gitlab_list_repository_tree",
            description="List repository tree (files and directories)",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "path": {
                        "type": "string",
                        "description": "Path within repository (default: root)"
                    },
                    "ref": {
                        "type": "string",
                        "description": "Branch or commit reference (default: main)"
                    },
                    "recursive": {
                        "type": "boolean",
                        "description": "Get all files recursively"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_repository_archive",
            description="Download repository archive (zip/tar.gz)",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "format": {
                        "type": "string",
                        "description": "Archive format (zip, tar.gz, tar.bz2)"
                    },
                    "sha": {
                        "type": "string",
                        "description": "Commit SHA or branch name"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_list_project_hooks",
            description="List project webhooks",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                }
            }
        ),
        Tool(
            name="gitlab_create_project_hook",
            description="Create project webhook",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "url": {
                        "type": "string",
                        "description": "Webhook URL"
                    },
                    "push_events": {
                        "type": "boolean",
                        "description": "Trigger on push events"
                    },
                    "issues_events": {
                        "type": "boolean",
                        "description": "Trigger on issues events"
                    },
                    "merge_requests_events": {
                        "type": "boolean",
                        "description": "Trigger on merge request events"
                    },
                    "tag_push_events": {
                        "type": "boolean",
                        "description": "Trigger on tag push events"
                    },
                    "pipeline_events": {
                        "type": "boolean",
                        "description": "Trigger on pipeline events"
                    }
                },
                "required": ["url"]
            }
        )
    ]


async def handle_repository_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle repository tool calls."""
    if name == "gitlab_fork_project":
        return await handle_fork_project(arguments)
    elif name == "gitlab_list_commits":
        return await handle_list_commits(arguments)
    elif name == "gitlab_get_commit":
        return await handle_get_commit(arguments)
    elif name == "gitlab_compare_branches":
        return await handle_compare_branches(arguments)
    elif name == "gitlab_list_repository_tree":
        return await handle_list_repository_tree(arguments)
    elif name == "gitlab_get_repository_archive":
        return await handle_get_repository_archive(arguments)
    elif name == "gitlab_list_project_hooks":
        return await handle_list_project_hooks(arguments)
    elif name == "gitlab_create_project_hook":
        return await handle_create_project_hook(arguments)
    else:
        raise ValueError(f"Unknown repository tool: {name}")


# Phase 3: Advanced Repository Operations Handlers

async def handle_fork_project(args: Dict[str, Any]) -> List[TextContent]:
    """Fork a project to user's namespace or a group."""
    project = args["project"]
    cmd = ["api", f"projects/{project.replace('/', '%2F')}/fork", "--method", "POST"]
    
    if args.get("namespace"):
        cmd.extend(["--field", f"namespace={args['namespace']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_commits(args: Dict[str, Any]) -> List[TextContent]:
    """List commits in a project or branch."""
    cmd = ["api", "projects/:id/repository/commits"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("branch"):
        cmd.extend(["--field", f"ref_name={args['branch']}"])
    if args.get("author"):
        cmd.extend(["--field", f"author={args['author']}"])
    if args.get("since"):
        cmd.extend(["--field", f"since={args['since']}"])
    if args.get("until"):
        cmd.extend(["--field", f"until={args['until']}"])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_commit(args: Dict[str, Any]) -> List[TextContent]:
    """Get commit details by SHA."""
    sha = args["sha"]
    cmd = ["api", f"projects/:id/repository/commits/{sha}"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_compare_branches(args: Dict[str, Any]) -> List[TextContent]:
    """Compare two branches or commits."""
    from_ref = args["from"]
    to_ref = args["to"]
    cmd = ["api", f"projects/:id/repository/compare?from={from_ref}&to={to_ref}"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_repository_tree(args: Dict[str, Any]) -> List[TextContent]:
    """List repository tree (files and directories)."""
    cmd = ["api", "projects/:id/repository/tree"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("path"):
        cmd.extend(["--field", f"path={args['path']}"])
    if args.get("ref"):
        cmd.extend(["--field", f"ref={args['ref']}"])
    if args.get("recursive"):
        cmd.extend(["--field", "recursive=true"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_repository_archive(args: Dict[str, Any]) -> List[TextContent]:
    """Download repository archive (zip/tar.gz)."""
    format_type = args.get("format", "zip")
    cmd = ["api", f"projects/:id/repository/archive.{format_type}"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("sha"):
        cmd.extend(["--field", f"sha={args['sha']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_project_hooks(args: Dict[str, Any]) -> List[TextContent]:
    """List project webhooks."""
    cmd = ["api", "projects/:id/hooks"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_project_hook(args: Dict[str, Any]) -> List[TextContent]:
    """Create project webhook."""
    url = args["url"]
    cmd = ["api", "projects/:id/hooks", "--method", "POST"]
    cmd.extend(["--field", f"url={url}"])
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("push_events"):
        cmd.extend(["--field", f"push_events={str(args['push_events']).lower()}"])
    if args.get("issues_events"):
        cmd.extend(["--field", f"issues_events={str(args['issues_events']).lower()}"])
    if args.get("merge_requests_events"):
        cmd.extend(["--field", f"merge_requests_events={str(args['merge_requests_events']).lower()}"])
    if args.get("tag_push_events"):
        cmd.extend(["--field", f"tag_push_events={str(args['tag_push_events']).lower()}"])
    if args.get("pipeline_events"):
        cmd.extend(["--field", f"pipeline_events={str(args['pipeline_events']).lower()}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]