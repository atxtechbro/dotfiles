"""Merge request handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_merge_request_tools() -> List[Tool]:
    """Get merge request management tools."""
    return [
        # Phase 5: Advanced Merge Request Operations
        Tool(
            name="gitlab_create_merge_request",
            description="Create a new merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "title": {
                        "type": "string",
                        "description": "Merge request title"
                    },
                    "description": {
                        "type": "string",
                        "description": "Merge request description"
                    },
                    "source_branch": {
                        "type": "string",
                        "description": "Source branch name"
                    },
                    "target_branch": {
                        "type": "string",
                        "description": "Target branch name (default: main)"
                    },
                    "assignees": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Assignee usernames"
                    },
                    "reviewers": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Reviewer usernames"
                    },
                    "labels": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Merge request labels"
                    },
                    "milestone": {
                        "type": "string",
                        "description": "Milestone title"
                    },
                    "draft": {
                        "type": "boolean",
                        "description": "Create as draft merge request"
                    },
                    "squash": {
                        "type": "boolean",
                        "description": "Squash commits when merging"
                    },
                    "remove_source_branch": {
                        "type": "boolean",
                        "description": "Remove source branch after merge"
                    }
                },
                "required": ["title", "source_branch"]
            }
        ),
        Tool(
            name="gitlab_update_merge_request",
            description="Update an existing merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    },
                    "title": {
                        "type": "string",
                        "description": "New title"
                    },
                    "description": {
                        "type": "string",
                        "description": "New description"
                    },
                    "target_branch": {
                        "type": "string",
                        "description": "New target branch"
                    },
                    "assignees": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Assignee usernames"
                    },
                    "reviewers": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Reviewer usernames"
                    },
                    "labels": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Merge request labels"
                    },
                    "state": {
                        "type": "string",
                        "description": "State (opened, closed, merged)"
                    },
                    "milestone": {
                        "type": "string",
                        "description": "Milestone title"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_merge_merge_request",
            description="Merge a merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    },
                    "merge_commit_message": {
                        "type": "string",
                        "description": "Custom merge commit message"
                    },
                    "squash": {
                        "type": "boolean",
                        "description": "Squash commits when merging"
                    },
                    "remove_source_branch": {
                        "type": "boolean",
                        "description": "Remove source branch after merge"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_close_merge_request",
            description="Close a merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_reopen_merge_request",
            description="Reopen a closed merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_list_mr_comments",
            description="List comments on a merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
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
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_create_mr_comment",
            description="Create a comment on a merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    },
                    "body": {
                        "type": "string",
                        "description": "Comment text"
                    }
                },
                "required": ["mr_id", "body"]
            }
        ),
        Tool(
            name="gitlab_get_mr_diff",
            description="Get merge request diff",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_get_mr_changes",
            description="Get merge request changes (files modified)",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_approve_merge_request",
            description="Approve a merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    }
                },
                "required": ["mr_id"]
            }
        ),
        Tool(
            name="gitlab_unapprove_merge_request",
            description="Remove approval from a merge request",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "mr_id": {
                        "type": "integer",
                        "description": "Merge request ID"
                    }
                },
                "required": ["mr_id"]
            }
        ),
    ]


async def handle_merge_request_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle merge request tool calls."""
    # Merge Request Operations
    if name == "gitlab_create_merge_request":
        return await handle_create_merge_request(arguments)
    elif name == "gitlab_update_merge_request":
        return await handle_update_merge_request(arguments)
    elif name == "gitlab_merge_merge_request":
        return await handle_merge_merge_request(arguments)
    elif name == "gitlab_close_merge_request":
        return await handle_close_merge_request(arguments)
    elif name == "gitlab_reopen_merge_request":
        return await handle_reopen_merge_request(arguments)
    elif name == "gitlab_list_mr_comments":
        return await handle_list_mr_comments(arguments)
    elif name == "gitlab_create_mr_comment":
        return await handle_create_mr_comment(arguments)
    elif name == "gitlab_get_mr_diff":
        return await handle_get_mr_diff(arguments)
    elif name == "gitlab_get_mr_changes":
        return await handle_get_mr_changes(arguments)
    elif name == "gitlab_approve_merge_request":
        return await handle_approve_merge_request(arguments)
    elif name == "gitlab_unapprove_merge_request":
        return await handle_unapprove_merge_request(arguments)
    else:
        raise ValueError(f"Unknown merge request tool: {name}")


async def handle_create_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Create a new merge request."""
    cmd = ["mr", "create", "--title", args["title"], "--source-branch", args["source_branch"]]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("description"):
        cmd.extend(["--description", args["description"]])
    if args.get("target_branch"):
        cmd.extend(["--target-branch", args["target_branch"]])
    if args.get("assignees"):
        cmd.extend(["--assignee", ",".join(args["assignees"])])
    if args.get("reviewers"):
        cmd.extend(["--reviewer", ",".join(args["reviewers"])])
    if args.get("labels"):
        cmd.extend(["--label", ",".join(args["labels"])])
    if args.get("milestone"):
        cmd.extend(["--milestone", args["milestone"]])
    if args.get("draft"):
        cmd.append("--draft")
    if args.get("squash"):
        cmd.append("--squash")
    if args.get("remove_source_branch"):
        cmd.append("--remove-source-branch")
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_update_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Update an existing merge request."""
    cmd = ["mr", "update", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("title"):
        cmd.extend(["--title", args["title"]])
    if args.get("description"):
        cmd.extend(["--description", args["description"]])
    if args.get("target_branch"):
        cmd.extend(["--target-branch", args["target_branch"]])
    if args.get("assignees"):
        cmd.extend(["--assignee", ",".join(args["assignees"])])
    if args.get("reviewers"):
        cmd.extend(["--reviewer", ",".join(args["reviewers"])])
    if args.get("labels"):
        cmd.extend(["--label", ",".join(args["labels"])])
    if args.get("state"):
        cmd.extend(["--state", args["state"]])
    if args.get("milestone"):
        cmd.extend(["--milestone", args["milestone"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_merge_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Merge a merge request."""
    cmd = ["mr", "merge", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("merge_commit_message"):
        cmd.extend(["--message", args["merge_commit_message"]])
    if args.get("squash"):
        cmd.append("--squash")
    if args.get("remove_source_branch"):
        cmd.append("--remove-source-branch")
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_close_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Close a merge request."""
    cmd = ["mr", "close", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_reopen_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Reopen a closed merge request."""
    cmd = ["mr", "reopen", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_mr_comments(args: Dict[str, Any]) -> List[TextContent]:
    """List comments on a merge request."""
    cmd = ["api", f"projects/:id/merge_requests/{args['mr_id']}/notes"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("sort"):
        cmd.extend(["--field", f"sort={args['sort']}"])
    if args.get("limit"):
        cmd.extend(["--field", f"per_page={args['limit']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_create_mr_comment(args: Dict[str, Any]) -> List[TextContent]:
    """Create a comment on a merge request."""
    cmd = ["api", f"projects/:id/merge_requests/{args['mr_id']}/notes", "--method", "POST"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    cmd.extend(["--field", f"body={args['body']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_mr_diff(args: Dict[str, Any]) -> List[TextContent]:
    """Get merge request diff."""
    cmd = ["mr", "diff", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=result.get("output", str(result)))]


async def handle_get_mr_changes(args: Dict[str, Any]) -> List[TextContent]:
    """Get merge request changes (files modified)."""
    cmd = ["api", f"projects/:id/merge_requests/{args['mr_id']}/changes"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_approve_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Approve a merge request."""
    cmd = ["mr", "approve", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_unapprove_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Remove approval from a merge request."""
    cmd = ["mr", "unapprove", str(args["mr_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]