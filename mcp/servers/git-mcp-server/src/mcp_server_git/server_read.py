"""Git MCP server - read-only operations"""
import logging
from pathlib import Path
from typing import Sequence

import git
from mcp.server import Server
from mcp.server.session import ServerSession
from mcp.server.stdio import stdio_server
from mcp.types import (
    ClientCapabilities,
    ListRootsResult,
    RootsCapability,
    TextContent,
    Tool,
    Prompt,
    PromptArgument,
    PromptMessage,
    GetPromptResult,
)

from .logging_utils import log_tool_error, log_tool_success
from .base import (
    # Import models
    GitStatus, GitDiffUnstaged, GitDiffStaged, GitDiff, GitLog, GitShow,
    GitWorktreeList, GitRemote, GitBatch, GitReflog, GitBlame,
    GitDescribe, GitShortlog, GitBranchDelete,
    # Import enum
    GitTools, READ_ONLY_TOOLS,
    # Import functions
    git_status, git_diff_unstaged, git_diff_staged, git_diff, git_log, git_show,
    git_worktree_list, git_remote, git_batch, git_reflog, git_blame,
    git_describe, git_shortlog, git_branch_delete,
)

# Tools allowed in read-only server
ALLOWED_TOOLS = [tool.value for tool in READ_ONLY_TOOLS] + [
    GitTools.REMOTE.value,  # Only list action allowed
    GitTools.BATCH.value,   # Can run read-only commands
    GitTools.BRANCH_DELETE.value,  # Only local delete allowed
]

async def serve(repository: Path | None) -> None:
    logger = logging.getLogger(__name__)

    if repository is not None:
        try:
            git.Repo(repository)
            logger.info(f"Using repository at {repository}")
        except git.InvalidGitRepositoryError:
            logger.error(f"{repository} is not a valid Git repository")
            return

    server = Server("mcp-git-read")

    @server.list_tools()
    async def list_tools() -> list[Tool]:
        return [
            Tool(
                name=GitTools.STATUS,
                description="Shows the working tree status",
                inputSchema=GitStatus.schema(),
            ),
            Tool(
                name=GitTools.DIFF_UNSTAGED,
                description="Shows changes in the working directory that are not yet staged",
                inputSchema=GitDiffUnstaged.schema(),
            ),
            Tool(
                name=GitTools.DIFF_STAGED,
                description="Shows changes that are staged for commit",
                inputSchema=GitDiffStaged.schema(),
            ),
            Tool(
                name=GitTools.DIFF,
                description="Shows differences between branches or commits",
                inputSchema=GitDiff.schema(),
            ),
            Tool(
                name=GitTools.LOG,
                description="Shows the commit logs",
                inputSchema=GitLog.schema(),
            ),
            Tool(
                name=GitTools.SHOW,
                description="Shows the contents of a commit",
                inputSchema=GitShow.schema(),
            ),
            Tool(
                name=GitTools.WORKTREE_LIST,
                description="List all worktrees",
                inputSchema=GitWorktreeList.schema(),
            ),
            Tool(
                name=GitTools.REFLOG,
                description="Show the reference log (reflog) for recovery and history inspection",
                inputSchema=GitReflog.schema(),
            ),
            Tool(
                name=GitTools.BLAME,
                description="Show who last modified each line of a file",
                inputSchema=GitBlame.schema(),
            ),
            Tool(
                name=GitTools.DESCRIBE,
                description="Generate human-readable names for commits based on tags",
                inputSchema=GitDescribe.schema(),
            ),
            Tool(
                name=GitTools.SHORTLOG,
                description="Summarize git log by contributor",
                inputSchema=GitShortlog.schema(),
            ),
            Tool(
                name=GitTools.REMOTE,
                description="List remote repositories (read-only: list action only)",
                inputSchema=GitRemote.schema(),
            ),
            Tool(
                name=GitTools.BATCH,
                description="Execute multiple read-only git commands in sequence",
                inputSchema=GitBatch.schema(),
            ),
            Tool(
                name=GitTools.BRANCH_DELETE,
                description="Delete local branches only (remote deletion not allowed)",
                inputSchema=GitBranchDelete.schema(),
            ),
        ]

    @server.list_prompts()
    async def list_prompts() -> list[Prompt]:
        """List available git-related prompts"""
        return [
            Prompt(
                name="commit-message",
                description="Analyze commit patterns against principles and identify procedural gaps",
                arguments=[
                    PromptArgument(
                        name="commit_count",
                        description="Number of recent commits to analyze (default: 100)",
                        required=False
                    )
                ]
            ),
            Prompt(
                name="pr-description", 
                description="Generate comprehensive PR descriptions from git diff and commit history",
                arguments=[
                    PromptArgument(
                        name="base_branch",
                        description="Base branch for comparison (default: main)",
                        required=False
                    )
                ]
            )
        ]

    @server.get_prompt()
    async def get_prompt(name: str, arguments: dict | None = None) -> GetPromptResult:
        """Get a specific prompt with git context injected"""
        if arguments is None:
            arguments = {}
            
        # Get git context from available repositories
        repos = await list_repos()
        if not repos:
            return GetPromptResult(
                description=f"Prompt: {name}",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(
                            type="text",
                            text="No git repository found. Please run this from a git repository."
                        )
                    )
                ]
            )
        
        # Use the first available repository
        repo_path = repos[0]
        try:
            repo = git.Repo(repo_path)
        except git.InvalidGitRepositoryError:
            return GetPromptResult(
                description=f"Prompt: {name}",
                messages=[
                    PromptMessage(
                        role="user", 
                        content=TextContent(
                            type="text",
                            text=f"Invalid git repository: {repo_path}"
                        )
                    )
                ]
            )
        
        if name == "commit-message":
            # Get extended git log for pattern analysis
            commit_count = int(arguments.get("commit_count", 100))
            
            try:
                log = git_log(repo, commit_count)
            except Exception as e:
                log = ["Unable to get git log"]
            
            prompt_text = f"""# Commit Pattern Analysis Against Principles

You are an expert at analyzing development patterns and identifying gaps between stated principles and actual practice. Based on my recent commit history, help me understand what my work patterns reveal about my priorities and where my procedures might be failing me.

## My Core Principles

**Systems Stewardship**: Maintaining and improving systems through consistent patterns, documentation, and procedures that enable sustainable growth and knowledge transfer.

**Versioning Mindset**: Progress through iteration rather than reinvention, where small strategic changes compound over time through active feedback loops.

**Subtraction Creates Value**: Strategic removal often creates more value than addition.

**Tracer Bullets**: Rapid feedback-driven development with ground truth at each step.

**Invent and Simplify**: Emphasis on simplification, malleability, usefulness, and utilitarian design.

**Do, Don't Explain**: Act like an agent, not a chatbot. Execute tasks directly rather than outputting walls of text.

**Transparency in Agent Work**: Make agent reasoning visible, especially during post-feature review cycles.

## Context

**Recent Commits (last {commit_count} commits):**
```
{chr(10).join(log)}
```

## Analysis Questions

1. **Principle Representation**: Which principles are over/under-represented in my commit patterns?

2. **Tension Points**: What tensions between principles show up in my work? (e.g., Do, Don't Explain vs Transparency in Agent Work)

3. **Procedural Gaps**: What procedures seem to be missing or not serving me well based on repeated patterns?

4. **Systems Stewardship Health**: Am I building sustainable, transferable knowledge or creating tribal knowledge?

5. **Iteration vs Reinvention**: Are my changes building on previous work or starting from scratch too often?

## Task

Analyze my commit patterns and provide:

1. **Principle Alignment**: Which principles are well-represented vs neglected in my actual work
2. **Hidden Tensions**: What conflicts between principles are showing up in practice
3. **Procedural Recommendations**: What new procedures or rule changes would serve me better
4. **Pattern Insights**: What does my commit history reveal about my actual priorities vs stated ones

Be direct and actionable. Focus on gaps between intention and execution."""

            return GetPromptResult(
                description="Analyze commit patterns against principles and identify procedural gaps",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(type="text", text=prompt_text)
                    )
                ]
            )
            
        elif name == "pr-description":
            # Get git context
            base_branch = arguments.get("base_branch", "main")
            try:
                log = git_log(repo, 10)
                # Try to get diff from base branch, fallback to recent commits
                try:
                    diff_output = repo.git.diff(f"{base_branch}..HEAD")
                except:
                    diff_output = repo.git.diff("HEAD~5..HEAD")
                status = git_status(repo)
            except Exception as e:
                log = ["Unable to get git log"]
                diff_output = "Unable to get git diff"
                status = "Unable to get git status"
            
            prompt_text = f"""# Pull Request Description Generator

You are an expert at writing clear, comprehensive pull request descriptions. Based on the changes and commit history, generate a PR description that helps reviewers understand the changes.

## Guidelines

- Start with a clear summary of what this PR does
- Include motivation/context for the changes
- List key changes and their impact
- Highlight any breaking changes
- Include testing information
- Add any relevant screenshots or examples

## Context

**Recent Commits:**
```
{chr(10).join(log)}
```

**All Changes:**
```
{diff_output}
```

**Current Status:**
```
{status}
```

## Parameters

- Base branch: {base_branch}

## Task

Generate a comprehensive PR description that includes:

1. **Summary**: What does this PR do?
2. **Motivation**: Why are these changes needed?
3. **Changes**: Key modifications made
4. **Testing**: How were these changes tested?
5. **Breaking Changes**: Any breaking changes (if applicable)
6. **Additional Notes**: Anything else reviewers should know

Format the output as markdown suitable for GitHub PR description."""

            return GetPromptResult(
                description="Generate comprehensive PR descriptions from git diff and commit history",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(type="text", text=prompt_text)
                    )
                ]
            )
        
        else:
            return GetPromptResult(
                description=f"Unknown prompt: {name}",
                messages=[
                    PromptMessage(
                        role="user",
                        content=TextContent(
                            type="text",
                            text=f"Unknown prompt: {name}. Available prompts: commit-message, pr-description"
                        )
                    )
                ]
            )

    async def list_repos() -> Sequence[str]:
        async def by_roots() -> Sequence[str]:
            if not isinstance(server.request_context.session, ServerSession):
                raise TypeError("server.request_context.session must be a ServerSession")

            if not server.request_context.session.check_client_capability(
                ClientCapabilities(roots=RootsCapability())
            ):
                return []

            roots_result: ListRootsResult = await server.request_context.session.list_roots()
            logger.debug(f"Roots result: {roots_result}")
            repo_paths = []
            for root in roots_result.roots:
                path = root.uri.path
                try:
                    git.Repo(path)
                    repo_paths.append(str(path))
                except git.InvalidGitRepositoryError:
                    pass
            return repo_paths

        def by_commandline() -> Sequence[str]:
            return [str(repository)] if repository is not None else []

        cmd_repos = by_commandline()
        root_repos = await by_roots()
        return [*root_repos, *cmd_repos]

    @server.call_tool()
    async def call_tool(name: str, arguments: dict) -> list[TextContent]:
        # Check if tool is allowed in read-only server
        if name not in ALLOWED_TOOLS:
            error_msg = f"Tool '{name}' is not available in read-only server"
            log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, None, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]
            
        repo_path = Path(arguments["repo_path"])
        
        try:
            repo = git.Repo(repo_path)
            # Mark repo as read-only for special handling in functions
            repo._read_only_mode = True
        except git.InvalidGitRepositoryError as e:
            error_msg = f"Invalid git repository: {repo_path}"
            log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]
        except Exception as e:
            error_msg = f"Failed to access repository: {str(e)}"
            log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]

        try:
            match name:
                case GitTools.STATUS:
                    status = git_status(repo)
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Retrieved repository status", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Repository status:\n{status}"
                    )]

                case GitTools.DIFF_UNSTAGED:
                    diff = git_diff_unstaged(repo)
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Retrieved unstaged changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Unstaged changes:\n{diff}"
                    )]

                case GitTools.DIFF_STAGED:
                    diff = git_diff_staged(repo)
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Retrieved staged changes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Staged changes:\n{diff}"
                    )]

                case GitTools.DIFF:
                    diff = git_diff(repo, arguments["target"])
                    log_tool_success("atxtechbro-git-mcp-server-read", name, f"Retrieved diff with {arguments['target']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=f"Diff with {arguments['target']}:\n{diff}"
                    )]

                case GitTools.LOG:
                    log = git_log(repo, arguments.get("max_count", 10))
                    log_tool_success("atxtechbro-git-mcp-server-read", name, f"Retrieved {len(log)} commits", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text="Commit history:\n" + "\n".join(log)
                    )]

                case GitTools.SHOW:
                    result = git_show(repo, arguments["revision"])
                    log_tool_success("atxtechbro-git-mcp-server-read", name, f"Showed revision: {arguments['revision']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.WORKTREE_LIST:
                    result = git_worktree_list(repo)
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Listed worktrees", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.REFLOG:
                    result = git_reflog(repo, arguments.get("max_count", 30), arguments.get("ref"))
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Retrieved reflog", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BLAME:
                    result = git_blame(repo, arguments["file_path"], arguments.get("line_range"))
                    log_tool_success("atxtechbro-git-mcp-server-read", name, f"Retrieved blame for {arguments['file_path']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.DESCRIBE:
                    result = git_describe(repo, arguments.get("commit"), arguments.get("tags", True), 
                                        arguments.get("all", False), arguments.get("long", False))
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Generated description", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.SHORTLOG:
                    result = git_shortlog(repo, arguments.get("revision_range"), arguments.get("numbered", True),
                                        arguments.get("summary", True), arguments.get("email", False))
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Generated shortlog", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.REMOTE:
                    # Only allow list action in read-only mode
                    action = arguments.get("action", "list")
                    if action != "list":
                        error_msg = f"Remote action '{action}' not allowed in read-only mode. Only 'list' is permitted."
                        log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, repo_path, arguments)
                        return [TextContent(type="text", text=f"Error: {error_msg}")]
                    
                    result = git_remote(repo, "list")
                    log_tool_success("atxtechbro-git-mcp-server-read", name, "Listed remotes", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case GitTools.BATCH:
                    # Execute batch with only allowed tools
                    result = git_batch(repo, arguments["commands"], ALLOWED_TOOLS)
                    log_tool_success("atxtechbro-git-mcp-server-read", name, f"Executed {len(arguments['commands'])} commands", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=str(result)
                    )]

                case GitTools.BRANCH_DELETE:
                    # Only allow local branch deletion
                    if arguments.get("remote", False):
                        error_msg = "Remote branch deletion not allowed in read-only mode"
                        log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, repo_path, arguments)
                        return [TextContent(type="text", text=f"Error: {error_msg}")]
                    
                    result = git_branch_delete(repo, arguments["branch_name"], arguments.get("force", False), False)
                    log_tool_success("atxtechbro-git-mcp-server-read", name, f"Deleted local branch: {arguments['branch_name']}", repo_path, arguments)
                    return [TextContent(
                        type="text",
                        text=result
                    )]

                case _:
                    error_msg = f"Unknown tool: {name}"
                    log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, repo_path, arguments)
                    return [TextContent(type="text", text=f"Error: {error_msg}")]

        except Exception as e:
            error_msg = str(e)
            log_tool_error("atxtechbro-git-mcp-server-read", name, error_msg, repo_path, arguments)
            return [TextContent(type="text", text=f"Error: {error_msg}")]

    @server.list_roots()
    async def list_roots() -> list[dict]:
        return []

    options = server.create_initialization_options()
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, options, raise_exceptions=True)


def main():
    """Entry point for mcp-server-git-read command"""
    import sys
    repository = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    import asyncio
    asyncio.run(serve(repository))

if __name__ == "__main__":
    main()