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
        ),
        
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
        ),
        
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
        
        # Phase 2: User & Group Management
        elif name == "gitlab_get_user":
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
        
        # Phase 3: Advanced Repository Operations
        elif name == "gitlab_fork_project":
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
        
        # Phase 4: Comprehensive Issue Management
        elif name == "gitlab_create_issue":
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


# Phase 4: Comprehensive Issue Management Handlers

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
    issue_id = args["issue_id"]
    cmd = ["issue", "update", str(issue_id)]
    
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
    issue_id = args["issue_id"]
    cmd = ["issue", "close", str(issue_id)]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_reopen_issue(args: Dict[str, Any]) -> List[TextContent]:
    """Reopen a closed issue."""
    issue_id = args["issue_id"]
    cmd = ["issue", "reopen", str(issue_id)]
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
    result = await run_glab_command(cmd)
    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def handle_list_issue_comments(args: Dict[str, Any]) -> List[TextContent]:
    """List comments on an issue."""
    issue_id = args["issue_id"]
    cmd = ["api", f"projects/:id/issues/{issue_id}/notes"]
    
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
    issue_id = args["issue_id"]
    body = args["body"]
    cmd = ["api", f"projects/:id/issues/{issue_id}/notes", "--method", "POST"]
    cmd.extend(["--field", f"body={body}"])
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    
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
    name = args["name"]
    color = args["color"]
    cmd = ["api", "projects/:id/labels", "--method", "POST"]
    cmd.extend(["--field", f"name={name}"])
    cmd.extend(["--field", f"color={color}"])
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
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
    title = args["title"]
    cmd = ["api", "projects/:id/milestones", "--method", "POST"]
    cmd.extend(["--field", f"title={title}"])
    
    if args.get("project"):
        cmd.extend(["--repo", args["project"]])
    if args.get("description"):
        cmd.extend(["--field", f"description={args['description']}"])
    if args.get("due_date"):
        cmd.extend(["--field", f"due_date={args['due_date']}"])
    if args.get("start_date"):
        cmd.extend(["--field", f"start_date={args['start_date']}"])
    
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