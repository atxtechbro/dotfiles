"""GitLab MCP Server - Pipeline debugging focused wrapper around glab CLI."""

import json
import subprocess
import asyncio
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


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Server("gitlab-mcp-server")


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
            except json.JSONDecodeError:
                # Return raw text for non-JSON responses
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


@app.list_tools()
async def list_tools() -> List[Tool]:
    """List available GitLab tools."""
    return [
        # Pipeline Operations (Priority)
        Tool(
            name="gitlab_list_pipelines",
            description="List CI/CD pipelines for a project",
            inputSchema={
                "type": "object",
                "properties": {
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "branch": {
                        "type": "string",
                        "description": "Filter by branch name"
                    },
                    "status": {
                        "type": "string",
                        "description": "Filter by status (running, success, failed, canceled)"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Number of pipelines to return (default: 10)"
                    }
                }
            }
        ),
        Tool(
            name="gitlab_get_pipeline",
            description="Get details of a specific pipeline",
            inputSchema={
                "type": "object",
                "properties": {
                    "pipeline_id": {
                        "type": "integer",
                        "description": "Pipeline ID"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["pipeline_id"]
            }
        ),
        Tool(
            name="gitlab_get_pipeline_jobs",
            description="List jobs for a specific pipeline",
            inputSchema={
                "type": "object",
                "properties": {
                    "pipeline_id": {
                        "type": "integer",
                        "description": "Pipeline ID"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "status": {
                        "type": "string",
                        "description": "Filter by job status (running, success, failed, canceled)"
                    }
                },
                "required": ["pipeline_id"]
            }
        ),
        Tool(
            name="gitlab_get_job_log",
            description="Get logs for a specific job (critical for debugging)",
            inputSchema={
                "type": "object",
                "properties": {
                    "job_id": {
                        "type": "integer",
                        "description": "Job ID"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["job_id"]
            }
        ),
        Tool(
            name="gitlab_get_failed_jobs",
            description="Get all failed jobs from a pipeline with their logs",
            inputSchema={
                "type": "object",
                "properties": {
                    "pipeline_id": {
                        "type": "integer",
                        "description": "Pipeline ID"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    },
                    "include_logs": {
                        "type": "boolean",
                        "description": "Include job logs in response (default: true)"
                    }
                },
                "required": ["pipeline_id"]
            }
        ),
        Tool(
            name="gitlab_retry_job",
            description="Retry a failed job",
            inputSchema={
                "type": "object",
                "properties": {
                    "job_id": {
                        "type": "integer",
                        "description": "Job ID to retry"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["job_id"]
            }
        ),
        Tool(
            name="gitlab_cancel_pipeline",
            description="Cancel a running pipeline",
            inputSchema={
                "type": "object",
                "properties": {
                    "pipeline_id": {
                        "type": "integer",
                        "description": "Pipeline ID to cancel"
                    },
                    "project": {
                        "type": "string",
                        "description": "Project path (e.g., 'group/project'). Optional if in git repo."
                    }
                },
                "required": ["pipeline_id"]
            }
        ),
        
        # Phase 1: Core Repository Management
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
        
        # Basic GitLab Operations
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


@app.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle tool calls."""
    try:
        # Pipeline Operations
        if name == "gitlab_list_pipelines":
            return await handle_list_pipelines(arguments)
        elif name == "gitlab_get_pipeline":
            return await handle_get_pipeline(arguments)
        elif name == "gitlab_get_pipeline_jobs":
            return await handle_get_pipeline_jobs(arguments)
        elif name == "gitlab_get_job_log":
            return await handle_get_job_log(arguments)
        elif name == "gitlab_get_failed_jobs":
            return await handle_get_failed_jobs(arguments)
        elif name == "gitlab_retry_job":
            return await handle_retry_job(arguments)
        elif name == "gitlab_cancel_pipeline":
            return await handle_cancel_pipeline(arguments)
        
        # Phase 1: Core Repository Management
        # Project Management
        elif name == "gitlab_list_projects":
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
        
        # Basic GitLab Operations
        elif name == "gitlab_list_issues":
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
            raise ValueError(f"Unknown tool: {name}")
    except Exception as e:
        logger.error(f"Error in tool {name}: {e}")
        return [TextContent(type="text", text=f"Error: {str(e)}")]


async def handle_list_pipelines(args: Dict[str, Any]) -> List[TextContent]:
    """List CI/CD pipelines."""
    cmd = ["ci", "list", "--output", "json"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("branch"):
        cmd.extend(["--branch", args["branch"]])
    if args.get("status"):
        cmd.extend(["--status", args["status"]])
    if args.get("limit"):
        cmd.extend(["--limit", str(args["limit"])])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_pipeline(args: Dict[str, Any]) -> List[TextContent]:
    """Get pipeline details."""
    cmd = ["ci", "get", str(args["pipeline_id"]), "--output", "json"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_pipeline_jobs(args: Dict[str, Any]) -> List[TextContent]:
    """Get jobs for a pipeline."""
    cmd = ["api", f"projects/:id/pipelines/{args['pipeline_id']}/jobs"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("status"):
        cmd.extend(["--field", f"scope={args['status']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_job_log(args: Dict[str, Any]) -> List[TextContent]:
    """Get job log - critical for debugging."""
    cmd = ["ci", "trace", str(args["job_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=result.get("output", str(result)))]


async def handle_get_failed_jobs(args: Dict[str, Any]) -> List[TextContent]:
    """Get all failed jobs from a pipeline with their logs."""
    include_logs = args.get("include_logs", True)
    
    # First get all jobs for the pipeline
    jobs_cmd = ["api", f"projects/:id/pipelines/{args['pipeline_id']}/jobs"]
    if args.get("project"):
        jobs_cmd.extend(["--repo", args["project"]])
    
    jobs_result = await run_glab_command(jobs_cmd)
    
    # Filter failed jobs
    failed_jobs = []
    if isinstance(jobs_result, list):
        failed_jobs = [job for job in jobs_result if job.get("status") == "failed"]
    
    # Get logs for each failed job if requested
    if include_logs:
        for job in failed_jobs:
            try:
                log_cmd = ["ci", "trace", str(job["id"])]
                if args.get("project"):
                    log_cmd.extend(["--repo", args["project"]])
                
                log_result = await run_glab_command(log_cmd)
                job["log"] = log_result.get("output", str(log_result))
            except Exception as e:
                job["log_error"] = str(e)
    
    result = {
        "pipeline_id": args["pipeline_id"],
        "failed_jobs": failed_jobs,
        "total_failed": len(failed_jobs)
    }
    
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_retry_job(args: Dict[str, Any]) -> List[TextContent]:
    """Retry a failed job."""
    cmd = ["ci", "retry", str(args["job_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_cancel_pipeline(args: Dict[str, Any]) -> List[TextContent]:
    """Cancel a running pipeline."""
    cmd = ["ci", "cancel", str(args["pipeline_id"])]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_issues(args: Dict[str, Any]) -> List[TextContent]:
    """List issues."""
    cmd = ["issue", "list", "--output", "json"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("state"):
        cmd.extend(["--state", args["state"]])
    if args.get("assignee"):
        cmd.extend(["--assignee", args["assignee"]])
    if args.get("limit"):
        cmd.extend(["--limit", str(args["limit"])])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Get issue details."""
    cmd = ["issue", "view", str(args["issue_id"]), "--output", "json"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_merge_requests(args: Dict[str, Any]) -> List[TextContent]:
    """List merge requests."""
    cmd = ["mr", "list", "--output", "json"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("state"):
        cmd.extend(["--state", args["state"]])
    if args.get("assignee"):
        cmd.extend(["--assignee", args["assignee"]])
    if args.get("limit"):
        cmd.extend(["--limit", str(args["limit"])])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_merge_request(args: Dict[str, Any]) -> List[TextContent]:
    """Get merge request details."""
    cmd = ["mr", "view", str(args["mr_id"]), "--output", "json"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_get_file(args: Dict[str, Any]) -> List[TextContent]:
    """Get file contents."""
    file_path = args["file_path"]
    
    # Use glab API to get file contents
    cmd = ["api", f"projects/:id/repository/files/{file_path.replace('/', '%2F')}/raw"]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("branch"):
        cmd.extend(["--field", f"ref={args['branch']}"])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=result.get("output", str(result)))]


# Phase 1: Core Repository Management Handlers

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


async def main():
    """Main server entry point."""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())