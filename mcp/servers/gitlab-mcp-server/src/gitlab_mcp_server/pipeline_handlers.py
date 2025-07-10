"""Pipeline operations handlers for GitLab MCP server."""

import json
from typing import Any, Dict, List
from mcp.types import Tool, TextContent

from .utils import run_glab_command


def get_pipeline_tools() -> List[Tool]:
    """Get pipeline operation tools."""
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
    ]


async def handle_pipeline_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    """Handle pipeline tool calls."""
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
    else:
        raise ValueError(f"Unknown pipeline tool: {name}")


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